python3 << EndPython3
import collections
import os
import sys
import vim
from distutils.util import strtobool



def _get_python_binary(exec_prefix):
  try:
    default = vim.eval("g:pymode_python").strip()
  except vim.error:
    default = ""
  if default and os.path.exists(default):
    return default
  if sys.platform[:3] == "win":
    return exec_prefix / 'python.exe'
  return exec_prefix / 'bin' / 'python3'

def _get_pip(venv_path):
  if sys.platform[:3] == "win":
    return venv_path / 'Scripts' / 'pip.exe'
  return venv_path / 'bin' / 'pip'

def _get_virtualenv_site_packages(venv_path, pyver):
  if sys.platform[:3] == "win":
    return venv_path / 'Lib' / 'site-packages'
  return venv_path / 'lib' / f'python{pyver[0]}.{pyver[1]}' / 'site-packages'

def _initialize_isort_env(upgrade=False):
  pyver = sys.version_info[:3]
  if pyver < (3, 6, 2):
    print("Sorry, Isort requires Python 3.6.2+ to run.")
    return False

  from pathlib import Path
  import subprocess
  import venv
  virtualenv_path = Path(vim.eval("g:isort_virtualenv")).expanduser()
  virtualenv_site_packages = str(_get_virtualenv_site_packages(virtualenv_path, pyver))
  first_install = False
  if not virtualenv_path.is_dir():
    print('Please wait, one time setup for Isort.')
    _executable = sys.executable
    _base_executable = getattr(sys, "_base_executable", _executable)
    try:
      executable = str(_get_python_binary(Path(sys.exec_prefix)))
      sys.executable = executable
      sys._base_executable = executable
      print(f'Creating a virtualenv in {virtualenv_path}...')
      print('(this path can be customized in .vimrc by setting g:isort_virtualenv)')
      venv.create(virtualenv_path, with_pip=True)
    except Exception:
      print('Encountered exception while creating virtualenv (see traceback below).')
      print(f'Removing {virtualenv_path}...')
      import shutil
      shutil.rmtree(virtualenv_path)
      raise
    finally:
      sys.executable = _executable
      sys._base_executable = _base_executable
    first_install = True
  if first_install:
    print('Installing Isort with pip...')
  if upgrade:
    print('Upgrading Isort with pip...')
  if first_install or upgrade:
    subprocess.run([str(_get_pip(virtualenv_path)), 'install', '-U', 'isort'], stdout=subprocess.PIPE)
    print('DONE! You are all set, thanks for waiting ✨ 🍰 ✨')
  if first_install:
    print('Pro-tip: to upgrade Isort in the future, use the :IsortUpgrade command and restart Vim.\n')
  if virtualenv_site_packages not in sys.path:
    sys.path.insert(0, virtualenv_site_packages)
  return True

if _initialize_isort_env():
  import isort
  import time

def Isort():
  start = time.time()
  config = isort.Config(settings_path=vim.eval("getcwd()"))
  quiet = vim.eval('g:isort_quiet')

  buffer_str = '\n'.join(vim.current.buffer) + '\n'
  try:
      new_buffer_str = isort.code(
        buffer_str,
      )
      if new_buffer_str == buffer_str:
        if not quiet:
          print(f'Already well formatted, good job. (took {time.time() - start:.4f}s)')
  except Exception as exc:
    print(exc)
  else:
    current_buffer = vim.current.window.buffer
    cursors = []
    for i, tabpage in enumerate(vim.tabpages):
      if tabpage.valid:
        for j, window in enumerate(tabpage.windows):
          if window.valid and window.buffer == current_buffer:
            cursors.append((i, j, window.cursor))
    vim.current.buffer[:] = new_buffer_str.split('\n')
    for i, j, cursor in cursors:
      window = vim.tabpages[i].windows[j]
      try:
        window.cursor = cursor
      except vim.error:
        window.cursor = (len(window.buffer), 0)
    if not quiet:
      print(f'Reformatted in {time.time() - start:.4f}s.')


def IsortUpgrade():
  _initialize_isort_env(upgrade=True)

def IsortVersion():
  print(f'Isort, version {isort.__version__} on Python {sys.version}.')

EndPython3

function isort#Isort()
  :py3 Isort()
endfunction

function isort#IsortUpgrade()
  :py3 IsortUpgrade()
endfunction

function isort#IsortVersion()
  :py3 IsortVersion()
endfunction
