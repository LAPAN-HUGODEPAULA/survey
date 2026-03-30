from app.integrations.clinical_writer.client import _infer_patient_ref, _pseudonymize_patient_ref


def test_pseudonymize_patient_ref_removes_raw_identifier() -> None:
    raw_identifier = "Patient@example.com"
    pseudonymized = _pseudonymize_patient_ref(raw_identifier)

    assert pseudonymized is not None
    assert pseudonymized.startswith("pt-")
    assert raw_identifier.lower() not in pseudonymized


def test_infer_patient_ref_prefers_stable_non_pii_identifier() -> None:
    payload = {
        "patient": {
            "medicalRecordId": "MR-12345",
            "email": "patient@example.com",
            "name": "Alice Example",
        }
    }

    inferred = _infer_patient_ref(payload)

    assert inferred == _pseudonymize_patient_ref("MR-12345")
