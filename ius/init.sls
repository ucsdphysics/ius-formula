# Completely ignore non-RHEL based systems
{% if grains['os_family'] == 'RedHat' %}

# A lookup table for IUS GPG keys & RPM URLs for various RedHat releases
{% if grains['os'] == 'RedHat' %}
  {% if grains['osmajorrelease'][0] == '5' %}
    {% set pkg= {
      'key': 'https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY',
      'key_hash': 'sha256=688852e2dba88a3836392adfc5a69a1f46863b78bb6ba54774a50fdecee7e38e',
      'rpm': 'https://rhel5.iuscommunity.org/ius-release.rpm',
    } %}
  {% elif grains['osmajorrelease'][0] == '6' %}
    {% set pkg= {
      'key': 'https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY',
      'key_hash': 'sha256=688852e2dba88a3836392adfc5a69a1f46863b78bb6ba54774a50fdecee7e38e',
      'rpm': 'https://rhel6.iuscommunity.org/ius-release.rpm',
    } %}
  {% elif grains['osmajorrelease'][0] == '7' %}
    {% set pkg= {
      'key': 'https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY',
      'key_hash': 'sha256=688852e2dba88a3836392adfc5a69a1f46863b78bb6ba54774a50fdecee7e38e',
      'rpm': 'https://rhel7.iuscommunity.org/ius-release.rpm',
    } %}
  {% endif %}
{% elif grains['os'] == 'CentOS' %}
  {% if grains['osmajorrelease'][0] == '5' %}
    {% set pkg= {
      'key': 'https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY',
      'key_hash': 'sha256=688852e2dba88a3836392adfc5a69a1f46863b78bb6ba54774a50fdecee7e38e',
      'rpm': 'https://centos5.iuscommunity.org/ius-release.rpm',
    } %}
  {% elif grains['osmajorrelease'][0] == '6' %}
    {% set pkg= {
      'key': 'https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY',
      'key_hash': 'sha256=688852e2dba88a3836392adfc5a69a1f46863b78bb6ba54774a50fdecee7e38e',
      'rpm': 'https://centos6.iuscommunity.org/ius-release.rpm',
    } %}
  {% elif grains['osmajorrelease'][0] == '7' %}
    {% set pkg= {
      'key': 'https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY',
      'key_hash': 'sha256=688852e2dba88a3836392adfc5a69a1f46863b78bb6ba54774a50fdecee7e38e',
      'rpm': 'https://centos7.iuscommunity.org/ius-release.rpm',
    } %}
  {% endif %}
{% elif grains['os'] == 'Amazon' and grains['osmajorrelease'] == '2014' %}
    {% set pkg= {
      'key': 'https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY',
      'key_hash': 'sha256=688852e2dba88a3836392adfc5a69a1f46863b78bb6ba54774a50fdecee7e38e',
      'rpm': 'https://centos6.iuscommunity.org/ius-release.rpm',
    } %}
{% elif grains['os'] == 'Amazon' and grains['osmajorrelease'] == '2015' %}
    {% set pkg= {
      'key': 'https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY',
      'key_hash': 'sha256=688852e2dba88a3836392adfc5a69a1f46863b78bb6ba54774a50fdecee7e38e',
      'rpm': 'https://centos6.iuscommunity.org/ius-release.rpm',
    } %}
{% endif %}


install_pubkey_ius:
  file.managed:
    - name: /etc/pki/rpm-gpg/IUS-COMMUNITY-GPG-KEY
    - source: {{ salt['pillar.get']('ius:pubkey', pkg.key) }}
    - source_hash:  {{ salt['pillar.get']('ius:pubkey_hash', pkg.key_hash) }}


ius_release:
  pkg.installed:
    - sources:
      - ius-release: {{ salt['pillar.get']('ius:rpm', pkg.rpm) }}
    - require:
      - file: install_pubkey_ius

set_pubkey_ius:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/ius.repo
    - pattern: '^gpgkey=.*'
    - repl: 'gpgkey=file:///etc/pki/rpm-gpg/IUS-COMMUNITY-GPG-KEY'
    - require:
      - pkg: ius_release

set_gpg_ius:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/ius.repo
    - pattern: 'gpgcheck=.*'
    - repl: 'gpgcheck=1'
    - require:
      - pkg: ius_release

{% if salt['pillar.get']('ius:disabled', False) %}
disable_ius:
  pkgrepo.managed:
    - name: ius
    - disabled: true
{% else %}
enable_ius:
  pkgrepo.managed:
    - name: ius
    - disabled: false
{% endif %}
{% endif %}
