FROM ghcr.io/cirruslabs/flutter:stable

RUN sudo apt-get update && sudo apt-get install -y \
    libglu1-mesa adb git curl unzip && \
    sudo apt-get clean

RUN flutter doctor
