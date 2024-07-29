FROM julia:1.10

# Set the working directory in the container
WORKDIR /app

# Copy the project files into the container
COPY . .

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Julia packages
RUN julia -e 'using Pkg; Pkg.add(["HTTP", "LightXML", "Dates", "Logging", "Telegram", "DotEnv"])'

# Create a .env file with placeholders for environment variables

# Set the command to run the Julia script
CMD ["julia", "main.jl"]