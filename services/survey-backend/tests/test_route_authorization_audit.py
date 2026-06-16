"""Dynamic route authorization audit.

Iterates over all registered FastAPI routes and asserts that every mutating
endpoint (POST, PUT, PATCH, DELETE) is either protected by a recognized
auth dependency or explicitly listed as a public exception.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from fastapi import APIRouter, FastAPI
from fastapi.routing import APIRoute
import pytest

from app.main import app

MUTATING_METHODS = {"POST", "PUT", "PATCH", "DELETE"}

PUBLIC_MUTATING_ROUTES: set[str] = {
    "/api/v1/screeners/register",
    "/api/v1/screeners/login",
    "/api/v1/screeners/recover-password",
    "/api/v1/patient_responses/",
    "/api/v1/patient_responses/{response_id}/send_report_email",
    "/api/v1/patient_responses/{response_id}/send_email",
    "/api/v1/survey_responses/",
    "/api/v1/survey_responses/{response_id}/send_report_email",
    "/api/v1/survey_responses/{response_id}/send_email",
    "/api/v1/builder/login",
    "/api/v1/builder/logout",
    "/api/v1/templates/{template_id}/preview",
    "/api/v1/privacy/requests",
    "/api/v1/privacy/requests/{request_id}",
}

PROTECTED_DEPENDENCY_NAMES = {
    "require_screener",
    "require_template_admin",
    "require_builder_admin",
    "require_builder_csrf",
    "_assert_privacy_admin",
}


def _collect_routes(fastapi_app: FastAPI) -> list[APIRoute]:
    routes: list[APIRoute] = []
    for route in fastapi_app.routes:
        if isinstance(route, APIRoute):
            routes.append(route)
        if hasattr(route, "app") and isinstance(route.app, FastAPI):
            routes.extend(_collect_routes(route.app))
    return routes


def _route_has_auth_dependency(route: APIRoute) -> bool:
    for dep in route.dependant.dependencies:
        if dep.call and hasattr(dep.call, "__name__"):
            if dep.call.__name__ in PROTECTED_DEPENDENCY_NAMES:
                return True
    for dep in route.dependencies:
        if hasattr(dep, "dependency") and hasattr(dep.dependency, "__name__"):
            if dep.dependency.__name__ in PROTECTED_DEPENDENCY_NAMES:
                return True
        elif hasattr(dep, "dependency") and hasattr(dep.dependency, "__wrapped__"):
            wrapped = dep.dependency.__wrapped__
            if hasattr(wrapped, "__name__") and wrapped.__name__ in PROTECTED_DEPENDENCY_NAMES:
                return True
    if route.dependant.dependencies:
        for dep in route.dependant.dependencies:
            call = dep.call
            if call is None:
                continue
            qualname = getattr(call, "__qualname__", "") or ""
            for name in PROTECTED_DEPENDENCY_NAMES:
                if name in qualname:
                    return True
            for param in route.dependant.query_params + route.dependant.body_params:
                if param.field_info and hasattr(param.field_info, "default"):
                    for name in PROTECTED_DEPENDENCY_NAMES:
                        if name in str(type(param.field_info.default)):
                            return True
    return False


def _path_matches_pattern(route_path: str, pattern: str) -> bool:
    import re
    regex = pattern.replace("{", "(?P<").replace("}", ">[^/]+)")
    return bool(re.match(f"^{regex}$", route_path))


@pytest.mark.parametrize(
    "route",
    [
        r
        for r in _collect_routes(app)
        if r.methods and r.methods & MUTATING_METHODS
    ],
    ids=lambda r: f"{next(iter(r.methods & MUTATING_METHODS), 'GET')} {r.path}",
)
def test_mutating_routes_have_auth_or_public_exception(route: APIRoute):
    if any(_path_matches_pattern(route.path, p) for p in PUBLIC_MUTATING_ROUTES):
        pytest.skip(f"Public exception: {route.path}")

    assert _route_has_auth_dependency(route), (
        f"Mutating route {route.methods} {route.path} has no recognized auth dependency. "
        f"Add Depends(require_screener), Depends(require_builder_admin), or list as a public exception."
    )
