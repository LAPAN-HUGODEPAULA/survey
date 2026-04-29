from app.domain.models.screener_model import Address, ProfessionalCouncil, ScreenerModel
from app.main import _ensure_reserved_system_screener
from app.persistence.repositories.screener_repo import SYSTEM_SCREENER_EMAIL, SYSTEM_SCREENER_ID


class FakeScreenerRepo:
    def __init__(self, screener: ScreenerModel | None) -> None:
        self.screener = screener
        self.ensure_calls: list[str] = []

    def find_by_id(self, screener_id: str) -> ScreenerModel | None:
        if self.screener and self.screener.id == screener_id:
            return self.screener
        return None

    def find_by_email(self, email: str) -> ScreenerModel | None:
        if self.screener and self.screener.email == email:
            return self.screener
        return None

    def ensure_system_screener(self, password_hash: str) -> ScreenerModel | None:
        self.ensure_calls.append(password_hash)
        if self.screener:
            self.screener.isBuilderAdmin = True
        return self.screener


def _screener(*, is_builder_admin: bool) -> ScreenerModel:
    return ScreenerModel(
        _id=SYSTEM_SCREENER_ID,
        cpf="00000000000",
        firstName="LAPAN",
        surname="System Screener",
        email=SYSTEM_SCREENER_EMAIL,
        password="existing-password-hash",
        phone="31984831284",
        address=Address(
            postalCode="34000000",
            street="Rua da Paisagem",
            number="220",
            complement="",
            neighborhood="Vale do Sereno",
            city="Nova Lima",
            state="MG",
        ),
        professionalCouncil=ProfessionalCouncil(type="none", registrationNumber=""),
        jobTitle="",
        degree="",
        isBuilderAdmin=is_builder_admin,
    )


def test_reserved_system_screener_is_promoted_when_admin_access_was_revoked() -> None:
    repo = FakeScreenerRepo(_screener(is_builder_admin=False))

    _ensure_reserved_system_screener(repo)

    assert repo.ensure_calls == ["existing-password-hash"]
    assert repo.screener is not None
    assert repo.screener.isBuilderAdmin is True
