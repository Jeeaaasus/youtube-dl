import aiofiles, asyncio, re, uuid
from fastapi import FastAPI, Request, Form, BackgroundTasks
from fastapi.responses import RedirectResponse, FileResponse, PlainTextResponse
from fastapi.templating import Jinja2Templates
from pathlib import Path


templates = Jinja2Templates(directory='/app/youtube-dl-webui/templates')
webserver = FastAPI()
youtubedl_binary = 'yt-dlp'


async def download_bg(url: str, download_id: str, youtubedl_args_format: str = ""):
    try:
        log_file_path = f'/tmp/download_{download_id}.log'
        log_file = await aiofiles.open(log_file_path, 'w')
        result = await asyncio.create_subprocess_shell(
            f'{youtubedl_binary} \'{url}\' --no-playlist-reverse --playlist-end \'-1\' --config-location \'/config/args.conf\' {youtubedl_args_format}',
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        async def write_output(stream, log_file):
            async for line in stream:
                decoded_line = line.decode()
                await log_file.write(decoded_line)
                await log_file.flush()
        await asyncio.gather(
            write_output(result.stdout, log_file),
            write_output(result.stderr, log_file)
        )
        await log_file.write('[youtube-dl] Download process ended\n')
        await log_file.close()
    except Exception as e:
        async with aiofiles.open(log_file_path, 'a') as log_file:
            await log_file.write(f"Error: {str(e)}\n")
            await log_file.flush()


def get_archive(archive_file='/config/archive.txt'):
    """Ensure that the archive file exists and return its path.

    This is a function so the path can be made configurable in the future.

    Returns:
        :obj:`str`: The full local path to the archive file.
    """
    if not Path(archive_file).exists():
        Path(archive_file).touch()
    return archive_file


@webserver.get('/favicon.ico')
async def favicon():
    return FileResponse('/app/youtube-dl-webui/static/favicon.png')


@webserver.get('/')
async def dashboard(request: Request):
    return templates.TemplateResponse('dashboard.html', {'request': request})


@webserver.post('/download')
async def download_url(request: Request, background_tasks: BackgroundTasks, url: str = Form(...)):
    if url:
        download_id = str(uuid.uuid4())
        async with aiofiles.open('/config/args.conf') as f:
            if re.search(r'(--format |-f )', await f.read(), flags=re.I | re.MULTILINE) is not None:
                youtubedl_args_format = ''
            else:
                youtubedl_args_format = youtubedl_default_args_format
        background_tasks.add_task(download_bg, url, download_id, youtubedl_args_format)
        return RedirectResponse(url=f'/download/{download_id}', status_code=303)
    return RedirectResponse(url='/', status_code=303)


@webserver.get('/download/{download_id}')
async def download_status(request: Request, download_id: str):
    return templates.TemplateResponse('dashboard.html', {'request': request,'download_id': download_id})


@webserver.get('/log/youtube-dl')
async def youtube_dl_log(request: Request):
    file_path = f'/var/log/youtube-dl/youtube-dl.log'
    try:
        async with aiofiles.open(file_path, 'r') as file:
            file_content = await file.read()
        return PlainTextResponse(file_content)
    except Exception as e:
        return PlainTextResponse(f"Error reading log file: {e}", status_code=500)


@webserver.get('/log/download/{filename}')
async def download_log(request: Request, filename: str):
    file_path = f'/tmp/download_{filename}.log'
    try:
        async with aiofiles.open(file_path, 'r') as file:
            file_content = await file.read()
        return PlainTextResponse(file_content)
    except Exception as e:
        return PlainTextResponse(f"Error reading file: {e}", status_code=500)


@webserver.get('/restart-youtube-dl')
async def restart_youtube_dl():
    await asyncio.create_subprocess_exec('supervisorctl', 'restart', 'youtube-dl')
    return RedirectResponse(url='/', status_code=303)


@webserver.get('/edit/args')
async def edit_args(request: Request):
    args = ''
    async with aiofiles.open('/config/args.conf') as f:
        async for line in f:
            args = args + line
    return templates.TemplateResponse('args.html', {'request': request, 'args': args})


@webserver.post('/edit/args/save')
async def save_args(args_new: list = Form(...)):
    async with aiofiles.open('/config/args.conf', mode='w') as f:
        for line in args_new:
            await f.write(line.replace('\r\n', '\n'))
    return RedirectResponse(url='/edit/args', status_code=303)


@webserver.get('/edit/channels')
async def edit_channels(request: Request):
    channels = ''
    async with aiofiles.open('/config/channels.txt') as f:
        async for line in f:
            channels = channels + line
    return templates.TemplateResponse('channels.html', {'request': request, 'channels': channels})


@webserver.post('/edit/channels/save')
async def save_channels(channels_new: list = Form(...)):
    async with aiofiles.open('/config/channels.txt', mode='w') as f:
        for line in channels_new:
            await f.write(line.replace('\r\n', '\n'))
    return RedirectResponse(url='/edit/channels', status_code=303)


@webserver.get('/edit/archive')
async def edit_archive(request: Request):
    archive = ''
    async with aiofiles.open(get_archive()) as f:
        async for line in f:
            archive = archive + line
    return templates.TemplateResponse('archive.html', {'request': request, 'archive': archive})


@webserver.post('/edit/archive/save')
async def save_archive(archive_new: list = Form(...)):
    async with aiofiles.open('/config/archive.txt', mode='w') as f:
        for line in archive_new:
            await f.write(line.replace('\r\n', '\n'))
    return RedirectResponse(url='/edit/archive', status_code=303)


with open('/config.default/format') as default_format:
    youtubedl_default_args_format = f'--format "{str(default_format.read()).strip()}"'
