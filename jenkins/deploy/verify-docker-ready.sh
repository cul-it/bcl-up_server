#!/bin/bash
source "scripts/log_utils.sh"
################################################################
## Script used to ensure docker is up and running in Jenkins  ##
################################################################

print_header "🛠 Checking Docker status and permissions"

if ! docker info > /dev/null 2>&1; then
  print_error "⚠️  Docker daemon is not running or permission denied."
  print_msg "🔄 Attempting to restart Docker"

  if sudo systemctl restart docker; then
    print_msg "✅ Docker service restarted. Verifying access"

    if docker info > /dev/null 2>&1; then
      print_success "🎉 Docker is now running and accessible."
    else
      print_line
      print_error "❌ Docker restarted, but access is still restricted."
      print_msg "🔍 Ensure the Jenkins user is in the 'docker' group:"
      print_msg "sudo usermod -aG docker jenkins"
      print_msg "ℹ️ Then re-login or reboot for the changes to take effect."
      print_line
      exit 1
    fi
  else
    print_line
    print_error "❌ Failed to restart Docker automatically."
    print_msg "👉 You may need to start it manually:"
    print_msg "sudo systemctl start docker"
    print_line
    exit 1
  fi
else
  print_success "✅ Docker is already running and accessible."
fi
