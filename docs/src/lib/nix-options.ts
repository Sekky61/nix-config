import { type } from 'arktype';
import rawOptions from '../../../result/options.json';

const nixValueSchema = type({
  text: 'string',
  "_type": 'string',
})

export type NixValue = typeof nixValueSchema.inferOut;

const optionMetaSchema = type({
  /**
   * strings are paths in nix storage
   * @example
   * "/nix/store/m1xfiylyaik91g6s5wj5nydd435kalhq-source/modules/audio.nix"
   */
  declarations: 'string[]',
  "default?": nixValueSchema,
  description: 'string?',
  "example?": nixValueSchema,
  loc: 'string[]',
  readOnly: 'boolean',
  type: 'string',
});

export type NixOption = typeof optionMetaSchema.inferOut;

const optionsSchema = type({
  '[string]': optionMetaSchema,
});

export type NixOptions = typeof optionsSchema.inferOut;

export const getNixOptions = () => {
  const parsed = optionsSchema(rawOptions);
  if (parsed instanceof type.errors) {
    console.error('Failed to validate options.json payload.', parsed);
    return null;
  }
  console.log('parsed', parsed);
  return parsed;
};
