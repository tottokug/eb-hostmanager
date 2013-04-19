import json, re, os

def build_envvars_file(envvars_file=None, config_file=None):
  if envvars_file is None:
    envvars_file = os.path.join(os.path.dirname(__file__), 'envvars.d', 'sysenv')
  if config_file is None:
    config_file = open(os.getenv('EB_CONFIG_FILE'))
  data = ''
  try:
    data = json.load(config_file)
  except ValueError:
    return

  with open(envvars_file, 'w') as fd:
    write_json_key_values(fd, data)

def write_json_key_values(file, json, prefix = 'EB_CONFIG'):
  for key, value in json.iteritems():
    key = re.sub('\\W', '_', key)
    if prefix == 'EB_CONFIG_PLUGINS_RDS_ENV' or \
        prefix == 'EB_CONFIG_ENV' or prefix == 'EB_CONFIG_ENVIRONMENT':
      prefix = None
    elif prefix is not None:
      key = key.upper()
    if isinstance(value, dict):
      write_json_key_values(file, value, '_'.join((prefix, key)))
    elif key == 'ENVIRONMENT' and isinstance(value, list):
      for val in value:
        file.write('export %s\n' % (val))
    else:
      if value is None:
        value = ''
      value = str(value).encode("string_escape")
      if prefix is None:
        pdata = ''
      else:
        pdata = prefix + '_'
      file.write('export %s%s="%s"\n' % (pdata, key, value))

if __name__ == '__main__':
  build_envvars_file()
