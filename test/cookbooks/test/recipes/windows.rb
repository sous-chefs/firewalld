# frozen_string_literal: true

node.override['firewall']['windows']['defaults'] = {
  policy: {
    input: 'blockinbound',
    output: 'blockoutbound',
  },
}
