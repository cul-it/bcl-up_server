#!/bin/bash
source "scripts/log_utils.sh"
#######################################################################################################
## Automatically checks for the correct version of Chromedriver and installs if necessary.           ##
## change the CHROMEDRIVER_VERSION_EXPECTED and CHROMEDRIVER_URL as needed to install a new version. ##
#######################################################################################################

print_header "💻 Executing chromedriver-verifier.sh"

CHROMEDRIVER_VERSION_EXPECTED="135.0.7049.52"
CHROMEDRIVER_URL="https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${CHROMEDRIVER_VERSION_EXPECTED}/linux64/chromedriver-linux64.zip"
INSTALL_PATH="/usr/lib64/chromium-browser/chromedriver"
print_msg "🔎  Checking for ChromeDriver Version: ${CHROMEDRIVER_VERSION_EXPECTED} at ${INSTALL_PATH}"

# Check installed version
CURRENT_VERSION=$($INSTALL_PATH --version 2>/dev/null | awk '{print $2}' || echo "none")

if [ "${CURRENT_VERSION}" == "${CHROMEDRIVER_VERSION_EXPECTED}" ]; then
  print_success "✅ Chromedriver ${CURRENT_VERSION} is already installed at ${INSTALL_PATH}. Skipping install."
else
  print_error "❌ ChromeDriver Version: ${CHROMEDRIVER_VERSION_EXPECTED} not found at ${INSTALL_PATH}."
  print_msg "⬇️ Installing ChromeDriver ${CHROMEDRIVER_VERSION_EXPECTED} to ${INSTALL_PATH}...."
  print_msg "Downloading ChromeDriver Version ${CHROMEDRIVER_VERSION_EXPECTED} from ${CHROMEDRIVER_URL}"
  wget -q -O chromedriver.zip "${CHROMEDRIVER_URL}"
  unzip -o -q chromedriver.zip
  cp -f chromedriver-linux64/chromedriver "${INSTALL_PATH}"
  rm -rf chromedriver-linux64 chromedriver.zip
  print_success "✅ ChromeDriver installed at ${INSTALL_PATH}."
fi

print_msg "Using ChromeDriver at: $(which chromedriver) (linked to '${INSTALL_PATH}')"
print_msg "Version: $(chromedriver --version)"