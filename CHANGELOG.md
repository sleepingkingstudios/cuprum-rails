# Changelog

## 0.1.0

Initial version.

### Collections

Implemented `Cuprum::Rails::Collection`.

Implemented `Cuprum::Rails::Repository`.

#### Commands

Implemented `Cuprum::Rails::Command`.

Implemented Rails collection commands:

- Implemented `Cuprum::Rails::Commands::AssignOne`.
- Implemented `Cuprum::Rails::Commands::BuildOne`.
- Implemented `Cuprum::Rails::Commands::DestroyOne`.
- Implemented `Cuprum::Rails::Commands::FindMany`.
- Implemented `Cuprum::Rails::Commands::FindMatching`.
- Implemented `Cuprum::Rails::Commands::FindOne`.
- Implemented `Cuprum::Rails::Commands::InsertOne`.
- Implemented `Cuprum::Rails::Commands::UpdateOne`.
- Implemented `Cuprum::Rails::Commands::ValidateOne`.

### Controllers

Implemented `Cuprum::Rails::Controller`.

Implemented `Cuprum::Rails::ControllerAction`.

Implemented `Cuprum::Rails::Controllers::Configuration`.

#### Actions

Implemented `Cuprum::Rails::Action`.

Implemented `Cuprum::Rails::Actions::ResourceAction`.

Implemented resourceful actions:

- Implemented `Cuprum::Rails::Actions::Create`.
- Implemented `Cuprum::Rails::Actions::Destroy`.
- Implemented `Cuprum::Rails::Actions::Edit`.
- Implemented `Cuprum::Rails::Actions::Index`.
- Implemented `Cuprum::Rails::Actions::New`.
- Implemented `Cuprum::Rails::Actions::Show`.
- Implemented `Cuprum::Rails::Actions::Update`.

#### Requests

Implemented `Cuprum::Rails::Request`.

#### Resources

Implemented `Cuprum::Rails::Resource`.

#### Responders

Implemented responders:

- Implemented `Cuprum::Rails::Responders::HtmlResponder`.
- Implemented `Cuprum::Rails::Responders::Html::PluralResource`.
- Implemented `Cuprum::Rails::Responders::Html::SingularResource`.
- Implemented `Cuprum::Rails::Responders::JsonResponder`.
- Implemented `Cuprum::Rails::Responders::Json::Resource`.

#### Routes

Implemented `Cuprum::Rails::Routes`.

Implemented resourceful routes:

- Implemented `Cuprum::Rails::Routing::PluralRoutes`.
- Implemented `Cuprum::Rails::Routing::SingularRoutes`.
