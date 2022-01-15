# Development

## Actions

- Remove ActionController::Parameters reference in Cuprum::Rails::Action.

Test cases:

- #create, #update (, #new ?) with generated attributes.
- #edit, #new with related resources

### Nested Resources

Interactions are optional - opt-in? With a DSL?

- With a required association (e.g. Chapter#book => /books/:book_id/chapters)
  - All actions: require :book_id, valid Book entity, response 'book' => book
- With a singular association (e.g. Book#author => /books)
  - #index: response 'books' => mapped books
  - #new, #edit: response 'books' => all books
  - #create, #show, #update, #destroy: response 'book' => mapped book
- With a plural association (e.g. Book#chapters)
  - #create: create associated chapters, response 'chapters' => created chapters
  - #show: response 'chapters' => mapped chapters
  - #destroy: destroy associated chapters, response 'chapters' => destroyed chapters

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
