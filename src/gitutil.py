import os
import subprocess
from datetime import datetime
from os.path import dirname as dn
from pathlib import Path
from typing import Union

from git import Repo
from git.config import GitConfigParser
from git.exc import InvalidGitRepositoryError, NoSuchPathError

from cfg import DISABLE_VCS, VCS_REPO_PATH
from src.logutil import initLogger

logger = initLogger("gitutil")
_default_path = dn(os.path.dirname(__file__)) + "/.darvester"


class GitUtil:
    def __init__(
        self,
        repo: Repo = None,
        cwd: Union[str, Path] = None,
        path: Union[str, Path] = VCS_REPO_PATH or _default_path,
    ):
        if not DISABLE_VCS:
            self._cwd = cwd or Path().parent.resolve()
            self._path = path
            try:
                self._repo = repo or Repo(self._path)
            except (NoSuchPathError, InvalidGitRepositoryError):
                self._repo = self.init_repo(self._path)
            self._gitconfig: GitConfigParser

    def open_repo(
        self, path: Union[str, Path] = VCS_REPO_PATH or _default_path
    ) -> Union[Repo, None]:
        """
        Opens a repo at the path specified

        :param path: the path to the repo
        :type path: Union[str, Path]
        :return: The Repo if it exists, None otherwise
        :rtype: Union[Repo, None]
        """
        if DISABLE_VCS:
            return None
        self._repo = Repo(path)
        return self._repo

    def init_repo(
        self, path: Union[str, Path] = VCS_REPO_PATH or _default_path
    ) -> Union[Repo, None]:
        """
        Initializes a Git repo at the path specified

        :param path: the path to the repo
        :type path: Union[str, Path]
        :return: The repo,
        :rtype: Union[Repo, None]
        """
        if DISABLE_VCS:
            return None
        logger.debug("Creating a repo at: %s", path)
        self._repo = Repo.init(_default_path, bare=False)
        return self._repo

    def commit(self, path: Union[str, Path] = VCS_REPO_PATH or _default_path):
        """
        Commits the repo at the path specified

        :param path: the path to the repo
        :type path: Union[str, Path]
        :return: None if the VCS is disabled
        :rtype: None
        """
        if DISABLE_VCS:
            return None
        os.chdir(path)
        __iter = len(os.listdir(path + "/users/")) + len(os.listdir(path + "/guilds/"))
        message = datetime.now().strftime(f"%m-%d-%Y_%H.%M.%S_{__iter}")
        logger.info(f"Committing {__iter} entries to the VCS: {message}...")
        _add_result = subprocess.run(
            ["git", "add", "--all"], stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        logger.debug((_add_result.returncode, _add_result.stdout, _add_result.stderr,))
        _commit_result = subprocess.run(
            ["git", "commit", "-m", message],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        logger.debug((_commit_result.returncode, _commit_result.stdout, _commit_result.stderr,))

        os.chdir(self._cwd)
