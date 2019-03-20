require 'aws-sdk'  # v2: require 'aws-sdk'
require 'base64'
class UpdateEcsService
  def initialize
    Aws.config.update({region: 'us-east-1',credentials: Aws::Credentials.new("#{ENV['AWS_ACCESS_KEY_DEV_OPS_OWN_ACCOUNT']}","#{ENV['AWS_SECRET_KEY_DEV_OPS_OWN_ACCOUNT']}")})
    @ecs = Aws::ECS::Client.new
    @service_discovery = Aws::ServiceDiscovery::Client.new
    @discovery_info = nil
  end

  def create_app_task_definition
    @ecs.register_task_definition({
      "ipc_mode": nil,
      "execution_role_arn": "arn:aws:iam::546124439885:role/ecsTaskExecutionRole",
      "container_definitions": [
        {
          "dns_search_domains": nil,
          "log_configuration": {
            "log_driver": "awslogs",
            "options": {
              "awslogs-group": "/ecs/automate-rapp",
              "awslogs-region": "us-east-1",
              "awslogs-stream-prefix": "ecs"
            }
          },
          "entry_point": nil,
          "port_mappings": [
            {
              "host_port": 3000,
              "protocol": "tcp",
              "container_port": 3000
            }
          ],
          "command": nil,
          "linux_parameters": nil,
          "cpu": 0,
          "environment": [],
          "resource_requirements": nil,
          "ulimits": nil,
          "dns_servers": nil,
          "mount_points": [],
          "working_directory": "/usr/src/app",
          "secrets": nil,
          "docker_security_options": nil,
          "memory": nil,
          "memory_reservation": nil,
          "volumes_from": [],
          "image": "madhantry/mdn-images:latest",
          "disable_networking": nil,
          "interactive": nil,
          "health_check": nil,
          "essential": true,
          "links": nil,
          "hostname": nil,
          "extra_hosts": nil,
          "pseudo_terminal": nil,
          "user": nil,
          "readonly_root_filesystem": nil,
          "docker_labels": nil,
          "system_controls": nil,
          "privileged": nil,
          "name": "rapp"
        }
      ],
      "placement_constraints": [],
      "memory": "1024",
      "task_role_arn": "arn:aws:iam::546124439885:role/ecsTaskExecutionRole",
      # "compatibilities": [
      #   "EC2",
      #   "FARGATE"
      # ],
      "family": "automate-rapp",
      "pid_mode": nil,
      "requires_compatibilities": [
        "FARGATE"
      ],
      "network_mode": "awsvpc",
      "cpu": "512",
      "volumes": []
    })

  end

  def create_db_task_definition
    @ecs.register_task_definition({
      "ipc_mode": nil,
      "execution_role_arn": "arn:aws:iam::546124439885:role/ecsTaskExecutionRole",
      "container_definitions": [
        {
          "dns_search_domains": nil,
          "log_configuration": {
            "log_driver": "awslogs",
            "options": {
              "awslogs-group": "/ecs/db",
              "awslogs-region": "us-east-1",
              "awslogs-stream-prefix": "ecs"
            }
          },
          "entry_point": nil,
          "port_mappings": [
            {
              "host_port": 3306,
              "protocol": "tcp",
              "container_port": 3306
            }
          ],
          "command": nil,
          "linux_parameters": nil,
          "cpu": 0,
          "environment": [
                    {
          "name": "MYSQL_ROOT_PASSWORD",
          "value": "root"
        }
            ],
          "resource_requirements": nil,
          "ulimits": nil,
          "dns_servers": nil,
          "mount_points": [],
          # "working_directory": "/usr/src/app",
          "secrets": nil,
          "docker_security_options": nil,
          "memory": nil,
          "memory_reservation": nil,
          "volumes_from": [],
          "image": "mysql:5.5.62",
          "disable_networking": nil,
          "interactive": nil,
          "health_check": nil,
          "essential": true,
          "links": nil,
          "hostname": nil,
          "extra_hosts": nil,
          "pseudo_terminal": nil,
          "user": nil,
          "readonly_root_filesystem": nil,
          "docker_labels": nil,
          "system_controls": nil,
          "privileged": nil,
          "name": "db"
        }
      ],
      "placement_constraints": [],
      "memory": "1024",
      "task_role_arn": "arn:aws:iam::546124439885:role/ecsTaskExecutionRole",
      # "compatibilities": [
      #   "EC2",
      #   "FARGATE"
      # ],
      "family": "db",
      "pid_mode": nil,
      "requires_compatibilities": [
        "FARGATE"
      ],
      "network_mode": "awsvpc",
      "cpu": "512",
      "volumes": []
    })
  end

  def create_ecs_service_for_db(service_discovery_arn)
    @ecs.create_service({
      cluster: "mdn-cluster",
      service_name: "db", # required
      task_definition: "db", # required
      desired_count: 1,
      launch_type: "FARGATE", # accepts EC2, FARGATE
      deployment_configuration: {
        maximum_percent: 200,
        minimum_healthy_percent: 100,
      },
      service_registries: [
        {
           container_name: "db",
           registry_arn: "#{service_discovery_arn}"
        }
     ],
      network_configuration: {
        awsvpc_configuration: {
          subnets: ["subnet-021d51d7a525615ac"], # required
          security_groups: ["sg-0d46377351f02ca34"],
          assign_public_ip: "ENABLED", # accepts ENABLED, DISABLED
        },
      },
      scheduling_strategy: "REPLICA", # accepts REPLICA, DAEMON
      deployment_controller: {
        type: "ECS", # required, accepts ECS, CODE_DEPLOY
      }
    })
  end


  def create_ecs_app_service
    @ecs.create_service({
      cluster: "mdn-cluster",
      service_name: "app", # required
      task_definition: "automate-rapp", # required
      desired_count: 1,
      launch_type: "FARGATE", # accepts EC2, FARGATE
      deployment_configuration: {
        maximum_percent: 200,
        minimum_healthy_percent: 100,
      },
       load_balancers: [
          {
            target_group_arn: "arn:aws:elasticloadbalancing:us-east-1:546124439885:targetgroup/mdn-circleci-poc-target-group/94f93f233aea2a17",
            load_balancer_name: "mdn-circleci-pipeline-elb",
            container_name: "rapp",
            container_port: 3000,
          },
        ],      
      network_configuration: {
        awsvpc_configuration: {
          subnets: ["subnet-021d51d7a525615ac"], # required
          security_groups: ["sg-0d46377351f02ca34"],
          assign_public_ip: "ENABLED", # accepts ENABLED, DISABLED
        },
      },
      scheduling_strategy: "REPLICA", # accepts REPLICA, DAEMON
      deployment_controller: {
        type: "ECS", # required, accepts ECS, CODE_DEPLOY
      }
    })
  end

  def run_app_migration_service
    @ecs.create_service({
      cluster: "mdn-cluster",
      service_name: "db_migrate", # required
      task_definition: "db_migrate", # required
      desired_count: 1,
      launch_type: "FARGATE", # accepts EC2, FARGATE
      deployment_configuration: {
        maximum_percent: 200,
        minimum_healthy_percent: 100,
      },
      network_configuration: {
        awsvpc_configuration: {
          subnets: ["subnet-021d51d7a525615ac"], # required
          security_groups: ["sg-0d46377351f02ca34"],
          assign_public_ip: "ENABLED", # accepts ENABLED, DISABLED
        },
      },
      scheduling_strategy: "REPLICA", # accepts REPLICA, DAEMON
      deployment_controller: {
        type: "ECS", # required, accepts ECS, CODE_DEPLOY
      }
    })
    terminate_condition_check("db_migrate")
  end

  def terminate_condition_check(service_name)
    begin
      app_task_arn = list_running_tasks_for_given_service("#{service_name}","RUNNING").task_arns.first
      unless app_task_arn.nil?
        describe_running_tasks(app_task_arn.split(":task/")[1],"#{service_name}")
      else
        terminate_condition_check(service_name)
      end
    rescue StandardError => e
      puts "Rescue portion, exact error is #{e.message}"
      terminate_condition_check(service_name)
    end
  end

  def run_db_creation_service
    @ecs.create_service({
      cluster: "mdn-cluster",
      service_name: "db_create", # required
      task_definition: "db_create", # required
      desired_count: 1,
      launch_type: "FARGATE", # accepts EC2, FARGATE
      deployment_configuration: {
        maximum_percent: 200,
        minimum_healthy_percent: 100,
      },
      network_configuration: {
        awsvpc_configuration: {
          subnets: ["subnet-021d51d7a525615ac"], # required
          security_groups: ["sg-0d46377351f02ca34"],
          assign_public_ip: "ENABLED", # accepts ENABLED, DISABLED
        },
      },
      scheduling_strategy: "REPLICA", # accepts REPLICA, DAEMON
      deployment_controller: {
        type: "ECS", # required, accepts ECS, CODE_DEPLOY
      }
    })
    terminate_condition_check("db_create")
  end

  def update_ecs_app_service
    @ecs.update_service({
    cluster: "mdn-cluster",
    service: "app", # required
    desired_count: 1,
    task_definition: "automate-rapp",
    deployment_configuration: {
      maximum_percent: 200,
      minimum_healthy_percent: 100,
    },
    load_balancers: [
          {
            target_group_arn: "arn:aws:elasticloadbalancing:us-east-1:546124439885:targetgroup/mdn-circleci-poc-target-group/94f93f233aea2a17",
            load_balancer_name: "mdn-circleci-pipeline-elb",
            container_name: "rapp",
            container_port: 3000,
          }
        ],    
    network_configuration: {
      awsvpc_configuration: {
        subnets: ["subnet-021d51d7a525615ac"], # required
        security_groups: ["sg-0d46377351f02ca34"],
        assign_public_ip: "ENABLED", # accepts ENABLED, DISABLED
      },
    },
   force_new_deployment: true
    })
  end

  def find_latest_application_task_definition
    @ecs.list_task_definitions({family_prefix: "rapp", status: "ACTIVE",sort: "DESC",max_results: 1}) #result will be array
  end

  def find_latest_db_task_definition
    @ecs.list_task_definitions({family_prefix: "db", status: "ACTIVE",sort: "DESC",max_results: 1,}) #result will be array
  end


  def get_cluster
    @ecs.list_clusters.cluster_arns.first
  end

  def get_list_of_task_definition
    @ecs.list_task_definitions
  end

  def list_services
    list_of_services = @ecs.list_services({
    cluster: "mdn-cluster",
    max_results: 50,
    launch_type: "FARGATE", # accepts EC2, FARGATE
    scheduling_strategy: "REPLICA", # accepts REPLICA, DAEMON
    })
  end

  def check_service_is_available?(service_name)
    list_services.first.service_arns.include?("arn:aws:ecs:us-east-1:546124439885:service/#{service_name}")
  end

  def create_db_service_discovery(vpc_id,given_name)
    created_name_space_info = create_namespace(vpc_id,given_name)
    sleep 120
    get_service_discovery_name_space(given_name)
    create_service_using_namespace(@discovery_info.id)
  end

  def create_service_using_namespace(namespce_id)
    service = @service_discovery.create_service({
      name: "db", # required
      namespace_id: "#{namespce_id}",
      description: "db service for rails app",
      dns_config: {
        namespace_id: "#{namespce_id}",
        routing_policy: "MULTIVALUE", # accepts MULTIVALUE, WEIGHTED
        dns_records: [ # required
          {
            type: "A", # required, accepts SRV, A, AAAA, CNAME
            ttl: 60, # required
          },
        ],
      },
      health_check_custom_config: {
        failure_threshold: 1
      }
    })
  end

  def create_namespace(vpc_id,given_name)
    @service_discovery.create_private_dns_namespace({
      name: "#{given_name}", # required
      # creator_request_id: "ResourceId",
      description: "Using automation",
      vpc: "#{vpc_id}", # required
    })
  end

  def get_service_discovery_name_space(given_name)
    @discovery_info ||= @service_discovery.list_namespaces.namespaces.collect{|x| x if x.name == "#{given_name}"}.first
  end

  def get_existing_service_discovery_arn(given_name)
    @service_discovery.list_services.services.collect{|x| x if x.name == "#{given_name}"}.first.arn
  end

  def do_deploy
    db_discovery_info = get_service_discovery_name_space("local")
    create_db_service_discovery("vpc-03de357ab424239d0","local") if db_discovery_info.nil?
    if !check_service_is_available?("db")
      create_db_task_definition
      create_ecs_service_for_db(get_existing_service_discovery_arn("db"))
    end
    run_db_creation_service if !check_service_is_available?("db_create")

    # sleep 10
    if check_service_is_available?("app")
      run_app_migration_service if !check_service_is_available?("db_migrate")
      create_app_task_definition
      update_ecs_app_service
    else
      run_app_migration_service
      create_app_task_definition
      create_ecs_app_service
    end
  end

  def list_running_tasks_for_given_service(service_name,desired_status)
    @ecs.list_tasks(
      {
        cluster: "mdn-cluster",
        max_results: 1,
        service_name: "#{service_name}",
        desired_status: "#{desired_status}", # accepts RUNNING, PENDING, STOPPED
        launch_type: "FARGATE", # accepts EC2, FARGATE
      }
    )
  end

  def describe_running_tasks(task_id,service_name)
    begin
      running_tasks = @ecs.describe_tasks({
      cluster: "mdn-cluster",
      tasks: ["#{task_id}"] # required
      })
      if (running_tasks.tasks.first.containers.first.name == "#{service_name}" && ["RUNNING","STOPPED"].include?("#{running_tasks.tasks.first.containers.first.last_status}"))
        delete_service(service_name)
      else
        describe_running_tasks(task_id,service_name)
      end
    rescue StandardError => e
      puts "Rescue portion, exact error is #{e.message}"
      describe_running_tasks(task_id,service_name)
    end
  end

  def delete_service(service_name)
    @ecs.delete_service(
      {
          cluster: "mdn-cluster",
          service: "#{service_name}", # required
          force: true,
      })
  end
end
ecs = UpdateEcsService.new
ecs.do_deploy
