version = "1.0"

train {
    step preproc_agg {
        image = "basisai/workload-standard:v0.1.2"
        install = [
            "pip3 install --upgrade pip",
            "pip3 install -r requirements-train.txt",
        ]
        script = [{sh = ["python3 preproc_agg.py"]}]
        resources {
            cpu = "0.5"
            memory = "1G"
        }
    }

    step features_trainer {
        image = "basisai/workload-standard:v0.1.2"
        install = [
            "pip3 install --upgrade pip",
            "pip3 install -r requirements-train.txt",
        ]
        script = [{sh = ["python3 features_trainer.py"]}]
        resources {
            cpu = "4"
            memory = "30G"
        }
         depends_on = ["preproc_agg"]
    }

    step train {
        image = "basisai/workload-standard:v0.1.2"
        install = [
            "pip3 install --upgrade pip",
            "pip3 install -r requirements-train.txt",
        ]
        script = [{sh = ["python3 train.py"]}]
        resources {
            cpu = "4"
            memory = "32G"
        }
        depends_on = ["features_trainer"]
    }

    parameters {
        EXECUTION_DATE = ""
        MODEL_VER = "lightgbm"
        NUM_LEAVES = "34"
    }
}

serve {
    image = "python:3.7"
    install = [
        "pip3 install --upgrade pip",
        "pip3 install -r requirements-serve.txt",
    ]
    script = [
        {sh = [
            "gunicorn --bind=:${BEDROCK_SERVER_PORT:-8080} --worker-class=gthread --workers=${WORKERS} --timeout=300 --preload serve_http:app"
        ]}
    ]

    parameters {
        WORKERS = "1"
    }
}
