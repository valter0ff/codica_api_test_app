# README

# Codica API test app

Projects management app

## Table of Contents

- [Project Overview](#project-overview)
- [Technologies Used](#technologies-used)
- [Installation](#installation)
- [Usage](#usage)
- [Linting](#linting)
- [Running Tests](#running-tests)
- [Generating Swagger Docs](#generating-swagger-docs)
- [License](#license)

## Project Overview

This is API RESTful project, that allows to register users and manage their projects with optional tasks

## Technologies Used

This project uses the following technologies:

- Ruby 3.3.7
- Rails 7.2
- PostgreSQL database
- Devise and Simple Token Authentication for authentication
- Rubocop for linting
- Rspec for testing
- Rswag for generating swagger documentation
- FactoryBot and Faker for seed data
- JSONAPI.rb and JSON:API Serializer Library for rendering json responses
- JsonMatchers to verify json responses structure

## Installation

To get a local copy up and running, follow these steps:

1. Clone the repository:

  ```bash
  git clone https://github.com/valter0ff/codica_api_test_app.git
  cd your-repository-name
  ```

2. Install dependencies:

  ```bash
  bundle install
  ```

3. Set up the database:

  ```bash
  bin/rails db:create
  bin/rails db:migrate
  ```

4. (Optional) Seed the database with sample data:

  ```bash
  bin/rails db:seed
  ```

## Usage
Once the app is installed and configured, you can run the Rails server:

  ```bash
  bin/rails server
  ```

This will start the application locally at http://localhost:3000

## Linting
To run linters
  ```bash
  bundle exec rubocop
  ```

## Running Tests
To run tests
  ```bash
  bundle exec rspec
  ```

## Generating Swagger Docs
To generate swagger docs
  ```bash
  rake rswag:specs:swaggerize SWAGGER_DRY_RUN=0
  ```
After it will be available at http://localhost:3000/api-docs/index.html

## License

This project is licensed under the MIT License.
