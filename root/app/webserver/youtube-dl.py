import subprocess
import aiofiles
from fastapi import FastAPI, Request, Form
from fastapi.responses import RedirectResponse
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


@webserver.get('/')
async def dashboard(request: Request):
    return templates.TemplateResponse('dashboard.html', {'request': request})


@webserver.get('/download')
async def download_url(request: Request):
    url = request.query_params.get('URL', False)
    print(url)
    execute(f'youtube-dl {url} --format "bestvideo[height<=1440][vcodec=vp9][fps>30]+bestaudio[acodec!=opus] / bestvideo[height<=1440][vcodec=vp9]+bestaudio[acodec!=opus] / bestvideo[height<=1440]+bestaudio[acodec!=opus] / best" --config-location "/config/args.conf"')
    print(url)
    return RedirectResponse(url='/', status_code=303)


@webserver.get('/edit/args')
async def configure_args(request: Request):
    args = ''
    async with aiofiles.open('/config/args.conf') as f:
        async for line in f:
            args = args + line
    return templates.TemplateResponse('args.html', {'request': request, 'args': args})


@webserver.post('/edit/args/save')
async def save_channels(args_new: list = Form(...)):
    async with aiofiles.open('/config/args.conf', mode='w') as f:
        for line in args_new:
            await f.write(line.replace('\r\n', '\n'))
    return RedirectResponse(url='/edit/args', status_code=303)


@webserver.get('/edit/channels')
async def configure_channels(request: Request):
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
async def configure_channels(request: Request):
    archive = ''
    async with aiofiles.open('/config/archive.txt') as f:
        async for line in f:
            archive = archive + line
    return templates.TemplateResponse('archive.html', {'request': request, 'archive': archive})


@webserver.post('/edit/archive/save')
async def save_channels(archive_new: list = Form(...)):
    async with aiofiles.open('/config/archive.txt', mode='w') as f:
        for line in archive_new:
            await f.write(line.replace('\r\n', '\n'))
    return RedirectResponse(url='/edit/archive', status_code=303)
