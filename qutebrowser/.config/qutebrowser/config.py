# pylint: disable=C0111
c = c  # noqa: F821 pylint: disable=E0602,C0103,W0127 # type: ignore
config = config  # noqa: F821 pylint: disable=E0602,C0103 # type: ignore

config.load_autoconfig()
config.source('gruvbox_dark_hard.py')
