# Changelog

## O.2.0

### Actions

Implemented `#transaction` method.

Refactored how actions handle required parameters.

### Controllers

Implemented `.build_request` class method.

Implemented `.default_format` configuration option.

Refactored `Cuprum::Rails::ControllerAction` to `Cuprum::Rails::Controllers::Action`.

#### Middleware

Implemented controller middleware.

- `Cuprum::Rails::Controllers::Middleware`.
- `Cuprum::Rails::Controllers::ClassMethods::Middleware`.

Updated `Cuprum::Rails::Controllers::Action` to apply configured middleware.

#### Requests

Added `#properties` method to access all request properties as a Hash.

**(Breaking Change)** Renamed `#method` property to `#http_method`.

#### Resources

Automatically generate a `Cuprum::Rails::Collection` when creating a resource with a `record_class` but no explicit `collection`.

#### Serializers

Implemented `Cuprum::Rails::Serializers::Context`.

Refactored serializers to take a `context:` keyword instead of `serializers:`.

Defined `Cuprum::Rails::RSpec::SerializersContracts`:

- `SHOULD_SERIALIZE_ATTRIBUTES`: Verifies that the specified attributes are serialized with the expected values.

## 0.1.0

Initial version.

### Collections

Implemented `Cuprum::Rails::Collection`.

Implemented `Cuprum::Rails::Repository`.

#### Commands

Implemented `Cuprum::Rails::Command`.

Implemented Rails collection commands:

- `Cuprum::Rails::Commands::AssignOne`.
- `Cuprum::Rails::Commands::BuildOne`.
- `Cuprum::Rails::Commands::DestroyOne`.
- `Cuprum::Rails::Commands::FindMany`.
- `Cuprum::Rails::Commands::FindMatching`.
- `Cuprum::Rails::Commands::FindOne`.
- `Cuprum::Rails::Commands::InsertOne`.
- `Cuprum::Rails::Commands::UpdateOne`.
- `Cuprum::Rails::Commands::ValidateOne`.

### Controllers

Implemented `Cuprum::Rails::Controller`.

Implemented `Cuprum::Rails::ControllerAction`.

Implemented `Cuprum::Rails::Controllers::Configuration`.

#### Actions

Implemented `Cuprum::Rails::Action`.

Implemented `Cuprum::Rails::Actions::ResourceAction`.

Implemented resourceful actions:

- `Cuprum::Rails::Actions::Create`.
- `Cuprum::Rails::Actions::Destroy`.
- `Cuprum::Rails::Actions::Edit`.
- `Cuprum::Rails::Actions::Index`.
- `Cuprum::Rails::Actions::New`.
- `Cuprum::Rails::Actions::Show`.
- `Cuprum::Rails::Actions::Update`.

#### Requests

Implemented `Cuprum::Rails::Request`.

#### Resources

Implemented `Cuprum::Rails::Resource`.

#### Responders

Implemented responders:

- `Cuprum::Rails::Responders::HtmlResponder`.
- `Cuprum::Rails::Responders::Html::PluralResource`.
- `Cuprum::Rails::Responders::Html::SingularResource`.
- `Cuprum::Rails::Responders::JsonResponder`.
- `Cuprum::Rails::Responders::Json::Resource`.

#### Responses

Implemented responses:

- `Cuprum::Rails::Responses::Html::RedirectResponse`
- `Cuprum::Rails::Responses::Html::RenderResponse`
- `Cuprum::Rails::Responses::JsonResponse`

#### Routes

Implemented `Cuprum::Rails::Routes`.

Implemented resourceful routes:

- `Cuprum::Rails::Routing::PluralRoutes`.
- `Cuprum::Rails::Routing::SingularRoutes`.

#### Serializers

Implemented JSON serializers:

- `Cuprum::Rails::Serializers::Json::ActiveRecordSerializer`.
- `Cuprum::Rails::Serializers::Json::ArraySerializer`.
- `Cuprum::Rails::Serializers::Json::AttributesSerializer`.
- `Cuprum::Rails::Serializers::Json::ErrorSerializer`.
- `Cuprum::Rails::Serializers::Json::HashSerializer`.
- `Cuprum::Rails::Serializers::Json::IdentitySerializer`.
- `Cuprum::Rails::Serializers::Json::Serializer`.
