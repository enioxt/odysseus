"""New non-admin accounts start with no privileges; an admin grants what each user needs."""
from core import auth as auth_mod


def test_default_privileges_grant_nothing_boolean():
    booleans = {k: v for k, v in auth_mod.DEFAULT_PRIVILEGES.items() if isinstance(v, bool)}
    granted = sorted(k for k, v in booleans.items() if v and k != "block_all_models")
    assert granted == [], f"default privileges grant {granted}"


def test_admin_privileges_still_full():
    for key in ("can_use_agent", "can_use_browser", "can_use_documents", "can_use_research",
                "can_generate_images", "can_manage_memory", "can_use_bash"):
        assert auth_mod.ADMIN_PRIVILEGES[key] is True
