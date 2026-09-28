"""リポジトリの土台が正しく構成されていることを確認するスモークテスト。"""

import healthsupportbank


def test_package_is_importable() -> None:
    """パッケージが import でき、バージョンが定義されていること。"""
    assert healthsupportbank.__version__
