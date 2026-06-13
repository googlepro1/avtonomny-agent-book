migrate((app) => {
  const collection = new Collection({
    name: 'subscribers',
    type: 'base',
    system: false,
    fields: [
      {
        name: 'email',
        type: 'email',
        required: true,
        unique: true,
      },
      {
        name: 'language',
        type: 'select',
        required: false,
        maxSelect: 1,
        values: ['ru', 'en'],
      },
      {
        name: 'source',
        type: 'text',
        required: false,
        max: 120,
      },
      {
        name: 'page',
        type: 'url',
        required: false,
      },
      {
        name: 'user_agent',
        type: 'text',
        required: false,
        max: 500,
      },
    ],
    indexes: [
      'CREATE UNIQUE INDEX idx_subscribers_email ON subscribers (email)',
    ],
    listRule: null,
    viewRule: null,
    createRule: '',
    updateRule: null,
    deleteRule: null,
    options: {},
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId('subscribers');
  return app.delete(collection);
});
