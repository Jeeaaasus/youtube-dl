import subprocess, aiofiles, re
from fastapi import FastAPI, Request, Form
from fastapi.responses import RedirectResponse, FileResponse
from fastapi.templating import Jinja2Templates


def execute(command):
    process = subprocess.Popen(command, shell=True, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = ''
    for line in iter(process.stdout.readline, ''):
        output += line
    process.wait()
    exit_code = process.returncode

    if exit_code == 0:
        return output
    else:
        raise Exception(command, exit_code, output)


templates = Jinja2Templates(directory='/app/webserver/templates')
webserver = FastAPI()

youtubedl_binary = 'yt-dlp'

@webserver.get('/')
async def dashboard(request: Request):
    return templates.TemplateResponse('dashboard.html', {'request': request})


@webserver.post('/download')
async def download_url(url: str = Form(...)):
    if url is not False:
        async with aiofiles.open('/config/args.conf') as f:
            if re.search(r'(--format |-f )', await f.read(), flags=re.I | re.MULTILINE) is not None:
                youtubedl_args_format = ''
            else:
                youtubedl_args_format = youtubedl_default_args_format
        execute(f'{youtubedl_binary} \'{url}\' --config-location \'/config/args.conf\' {youtubedl_args_format}')
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
    async with aiofiles.open('/config/archive.txt') as f:
        async for line in f:
            archive = archive + line
    return templates.TemplateResponse('archive.html', {'request': request, 'archive': archive})


@webserver.post('/edit/archive/save')
async def save_archive(archive_new: list = Form(...)):
    async with aiofiles.open('/config/archive.txt', mode='w') as f:
        for line in archive_new:
            await f.write(line.replace('\r\n', '\n'))
    return RedirectResponse(url='/edit/archive', status_code=303)


@webserver.get('/favicon.ico')
async def favicon():
    return FileResponse('/app/webserver/static/favicon.png')


with open('/config.default/format') as default_format:
    youtubedl_default_args_format = f'--format "{str(default_format.read()).strip()}"'
