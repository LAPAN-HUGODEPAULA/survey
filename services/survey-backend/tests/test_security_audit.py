from app.services.security_audit import compute_audit_hash


def test_audit_hash_chain_changes_with_prev_hash():
    payload = {"eventType": "privacy_request_created", "actor": {"email": "a@b.com"}}
    first = compute_audit_hash(payload, None)
    second = compute_audit_hash(payload, first)

    assert first != second
