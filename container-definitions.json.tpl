[
  {
    "essential": true,
    "image": "${app_image}",
    "name": "devpod-pro",
    "user": "root",
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ],
    "environment": [
      {
         "name": "K3S_DATASTORE_ENDPOINT",
         "value": "${datastore_endpoint}"
      },
      {
         "name": "ADMIN_PASSWORD_HASH",
         "value": "${admin_password_hash}"
      },
      {
         "name": "PRODUCT",
         "value": "devpod-pro"
      },
      {
         "name": "LOFT_HOST",
         "value": "${domain}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "mountPoints": [
      {
        "containerPath": "/var/lib/loft",
        "sourceVolume": "efs-loft"
      }
    ]
  }
]