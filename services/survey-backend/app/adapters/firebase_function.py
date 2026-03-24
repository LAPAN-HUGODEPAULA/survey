"""Expose the FastAPI app through Firebase HTTPS functions."""


from firebase_functions import https_fn
from firebase_admin import initialize_app
from app import app
from a2wsgi import ASGIMiddleware

initialize_app()

wsgi_app = ASGIMiddleware(app)

@https_fn.on_request()
def api(req: https_fn.Request) -> https_fn.Response:
    """Serve the FastAPI application through a Firebase HTTPS handler."""
    return https_fn.Response.from_app(wsgi_app, req)
