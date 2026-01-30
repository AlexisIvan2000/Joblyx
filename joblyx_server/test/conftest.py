import pytest

pytest_plugins = ('pytest_asyncio',)


@pytest.fixture
def sample_job_description_en():
    # Description d'emploi en anglais pour les tests
    return """
    We are looking for a Software Developer with experience in Python and JavaScript.

    Requirements:
    - 3+ years of experience with Python programming
    - Strong knowledge of React and Node.js
    - Experience with PostgreSQL and MongoDB databases
    - Familiarity with AWS cloud services
    - Experience with Docker and Kubernetes
    - Knowledge of Git version control
    - Understanding of REST API design
    - Agile methodology experience

    Nice to have:
    - Experience with TypeScript
    - Knowledge of Redis caching
    - CI/CD pipeline experience with GitHub Actions
    """


@pytest.fixture
def sample_job_description_fr():
    # Description d'emploi en français pour les tests
    return """
    Nous recherchons un Développeur logiciel avec expérience en Java et Python.

    Exigences:
    - 3+ ans d'expérience en programmation Java
    - Bonne connaissance de Spring Boot
    - Expérience avec PostgreSQL et MySQL
    - Familiarité avec les services cloud AWS
    - Expérience avec Docker
    - Connaissance de Git
    - Compréhension de la conception d'API REST
    - Méthodologie Agile

    Atouts:
    - Expérience avec Angular
    - Connaissance de Redis
    """


@pytest.fixture
def sample_job_description_ambiguous():
    # Description avec des noms de skills ambigus
    return """
    Requirements:
    - C programming language experience
    - Go programming and Golang development
    - R statistical analysis
    - Rust programming language
    - Swift developer for iOS
    """


@pytest.fixture
def mock_jsearch_response():
    # Réponse mock de l'API JSearch
    return {
        "data": [
            {
                "job_title": "Software Developer",
                "job_description": "Looking for Python developer with React experience.",
                "employer_name": "Tech Corp",
                "job_city": "Toronto",
                "job_country": "CA"
            },
            {
                "job_title": "Backend Developer",
                "job_description": "Java and Spring Boot experience required. PostgreSQL knowledge.",
                "employer_name": "Dev Inc",
                "job_city": "Montreal",
                "job_country": "CA"
            }
        ]
    }
