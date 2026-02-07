import pytest
from app.app import app

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_home(client):
    response = client.get('/')
    assert response.status_code == 200
    assert response.get_json() == {"message": "Hello, Flask!"}

def test_add(client):
    response = client.post('/add', json={"a": 3, "b": 4})
    assert response.status_code == 200
    assert response.get_json() == {"result": 7}
