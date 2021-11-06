# Development

## Actions

- Remove ActionController::Parameters reference in Cuprum::Rails::Action.

## Controllers

- Different cases for controllers.
  - Singular resource (e.g. /user => UsersController)
  - Plural resource (e.g. /books => BooksController)
  - Non-resourceful controllers (e.g. / => HomeController)
  - Nested resources (e.g. /user/profile => UserProfilesController, /books/:id/chapters => ChaptersController)
  - Stateful resources (e.g. /rockets/:id => RocketsController, assemble, fuel, launch, recover)

## Requests

- Convert parameters to a Hash with String keys.

## Resources

- Passing additional collections, e.g. "load a resource and associations"
  - Define Resource#repository?

## Responders

- Condense Html::PluralResource and Html::SingularResource ?
  - Check Responder#member_action? in relevant match blocks
