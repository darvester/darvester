import os
import subprocess

from datetime import datetime

from cfg import VCS_REPO_PATH
from git import Repo
from git.exc import NoSuchPathError, InvalidGitRepositoryError
from git.config import GitConfigParser
from os.path import dirname as dn
from src.logutil import initLogger
from pathlib import Path
from typing import Union

logger = initLogger("gitutil")
_default_path = dn(os.path.dirname(__file__)) + "/.darvester"


class GitUtil:
    def __init__(
            self,
            repo: Repo = None,
            cwd: Union[str, Path] = None,
            path: Union[str, Path] = VCS_REPO_PATH or _default_path
    ):
        self._cwd = cwd or Path().parent.resolve()
        self._path = path
        try:
            self._repo = repo or Repo(self._path)
        except (NoSuchPathError, InvalidGitRepositoryError):
            self._repo = self.init_repo(self._path)
        self._gitconfig: GitConfigParser

    def open_repo(self, path: Union[str, Path] = VCS_REPO_PATH or _default_path) -> Repo:
        self._repo = Repo(path)
        return self._repo

    def init_repo(self, path: Union[str, Path] = VCS_REPO_PATH or _default_path) -> Repo:
        logger.debug("Creating a repo at: %s" % (path,))
        self._repo = Repo.init(_default_path, bare=False)
        assert not self._repo.bare
        self._gitconfig = self._repo.config_reader()
        return self._repo

    def commit(self, path: Union[str, Path] = VCS_REPO_PATH or _default_path):
        """
        Args:
            path: the path where the database was dumped
        """
        os.chdir(path)
        __iter = len(os.listdir(path + '/users/')) + len(os.listdir(path + '/guilds/'))
        message = datetime.now().strftime(f"%m-%d-%Y_%H.%M.%S_{__iter}")
        logger.info(f"Committing {__iter} entries to the VCS: {message}...")
        with open(os.devnull, 'wb') as _devnull:
            subprocess.check_call(['git', 'add', '--all'], stdout=_devnull, stderr=subprocess.STDOUT)
            subprocess.check_call(["git", "commit", "-m", message], stdout=_devnull, stderr=subprocess.STDOUT)

        os.chdir(self._cwd)
