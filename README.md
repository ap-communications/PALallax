# PALallax

Check out the offical website at [http://www.ap-com.co.jp/ja/paloalto/palallax/](http://www.ap-com.co.jp/ja/paloalto/palallax/) .

PALallax is a traffic/threat viewer for Next Generation Firewalls(Palo Alto Networks).
PALallax collects the log of the next-generation firewall, to visualize the traffic and threats.

Viewable information is as follows.

- Threat Count
- CPU Usages
- Source/Destination Address
- Destination Country
- Application
- Threat Code/Severity
- Request URL
- Category
- System Temperature
- Fan Rotation Frequency

__NOTE:__

For software improvement, PALallax sends the information that matches the conditions to AP COMMUNICATIONS CO.,LTD. by __default__ .
Information to be transmitted are as follows:

- Source IP
- Destination IP
- Threat type(Medium and over)
- Destination Port
- Threat Direction
- Country
- GEOHash
- Threat ID
- Threat SubType

To stop transmit above informations to the threat collection server, delete or comment-out following `store` section:

````conf
# config/fluentd/td-agent.conf
<store>
  type wsrpc
  tag elastic.palo.snmp
  out_exec lib/ws_out_exec.rb
  uri wss://threatdb.ap-com.co.jp:443
</store>
````

## Feature Overview

Features of PALallax is as follows.

- Available free of charge.
- Visualize the log.
- Log viewing in real time.
- View long-term log.

## Diagram

![](https://raw.githubusercontent.com/ap-communications/PALallax/readme/images/palallax_overviews.jpg?token=AL1ImF6lBp3adcb9XjwixmjE1xUhOsfhks5VlSwGwA%3D%3D)

## Tested Platforms

In the following environment, we did check the operation of PALallax.

- PAN-OS 5.0.14
- CentOS 7.1
- c4.large@EC2
  - vCPU: 2
  - Mem(GiB): 3.75
- Ruby: 2.0.0p643
- Java: 1.8.0_45-b13


## Dependencies

PALallax works by using the following components.
How to install each component is included in the next chapter.

- [Ruby >= 2.0](https://rvm.io/rvm/install)
- Java >= 1.7.9
- ElasticSearch >= 1.4.0
- Fluentd
- kibana4
- nginx 1.9.2

## Getting Started

Installation procedure for PALallax is as below.(__this requires root privileges__)

### 1:PALallax

````bash
 yum install GeoIP GeoIP-devel git wget -y
 git clone https://github.com/ap-communications/PALallax
# Move to PALallax directory before following steps.
 cd PALallax/
````

### [2:Elasticsearch](https://github.com/elastic/elasticsearch#installation)

To use Elasticsearch you need to have a Java installed on your machine.
Required version is JVM >= 1.7.9, elasticsearch installation steps as follows:

````bash
 yum install java -y
 wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.4.4.tar.gz
 tar xvzf elasticsearch-1.4.4.tar.gz
 mkdir -p elasticsearch-1.4.4/data/elasticsearch/nodes/0/indices/
 mkdir -p elasticsearch-1.4.4/config/templates/
 cp -pf config/elasticsearch/templates/template_1.json elasticsearch-1.4.4/config/templates/
 cp -prf indices/.kibana/ elasticsearch-1.4.4/data/elasticsearch/nodes/0/indices/
 cp -prf indices/kibana-int/ elasticsearch-1.4.4/data/elasticsearch/nodes/0/indices/
 cp -prf indices/fluentd/ elasticsearch-1.4.4/data/elasticsearch/nodes/0/indices/
 \cp -pf config/elasticsearch/elasticsearch.yml elasticsearch-1.4.4/config/
````

-Xmx(i)g and -Xms(j)g args(ES\_HEAP\_SIZE) pass to Elasticsearch's option.
ES\_HEAP\_SIZE must be specifed half of equipped memory.(For example, the server has 20GB memory: i.e allocate 10GB to Elasticsearch)

````
 elasticsearch-1.4.4/bin/elasticsearch -Xmx10g -Xms10g -d
````

### 3:kibana4

````bash
 \cp -pf config/kibana/kibana.yml kibana4/config/
 nohup kibana4/bin/kibana >> /dev/null &
````
### [4:Fluentd](https://github.com/fluent/fluentd/#quick-start)

To use Fluent you need to have a Ruby installed on your machine.
Required version is Ruby >= 2.0, fluentd installation steps as follows:

#### Install dependencies for ruby runtime
````bash
 wget http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
 rpm -ivh epel-release-6-8.noarch.rpm
 yum install gcc-c++ patch readline readline-devel git -y
 yum install zlib zlib-devel libffi-devel -y
 yum install openssl-devel make bzip2 autoconf automake libtool bison -y
 yum install gdbm-devel tcl-devel tk-devel -y
 yum install libxslt-devel libxml2-devel curl-devel -y
 yum install --enablerepo=epel libyaml-devel -y
````

#### Install RVM(ruby version manager)
````bash
 gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
 curl -L https://get.rvm.io | sudo bash -s stable
````

#### Install ruby on open another terminal
````bash
 cd PALallax/
 rvm install 2.0.0
 rvm use 2.0.0
 ruby -v
 gem install fluentd --no-doc --no-ri
 ls -1R vendor/gems/ | grep -v vendor/gems/: | xargs -I{} gem install vendor/gems/{} --no-doc --no-ri
````

#### Configuration Fluentd(Scope of traffic analysis)

PALallax analyze traffic when it receives a Trap.  
About scope of analysis, you can select setting from the following.

+ Only for threat traffic
+ All traffic

The default setting is __threat traffic__.

##### Only for threat traffic

PALallax analyzes the only threat traffic.  
If the severity is no value , PALallax discards the Trap.

````bash
<source>
  type snmptrap       # required, choosing the input plugin.
  host 0.0.0.0        # optional, interface to listen on, default 0 for all.
  port 162            # optional, port to listen for traps, default is 162
  out_executor lib/snmp_out_exec.rb # Threat traffic plugin
  # out_executor lib/snmp_out_exec_all.rb # All traffic plugin
  tag palo.snmp  # optional, tag to assign to events, default is alert.snmptrap
</source>
````

##### All traffic

PALallax analyzes all of the traffic.  
NOTE: In this case, it will consume a lot of storage capacity.

````bash
<source>
  type snmptrap       # required, choosing the input plugin.
  host 0.0.0.0        # optional, interface to listen on, default 0 for all.
  port 162            # optional, port to listen for traps, default is 162
  # out_executor lib/snmp_out_exec.rb # Threat traffic plugin
  out_executor lib/snmp_out_exec_all.rb # All traffic plugin
  tag palo.snmp  # optional, tag to assign to events, default is alert.snmptrap
</source>
````

#### Configuration Fleuntd(SNMP Get/Traps)

This is an example configuration:
If you need to edit snmp settings, edit following sections.
````bash
# config/fluentd/td-agent.conf
<source>
  type snmptrap       # required, choosing the input plugin.
  host 0.0.0.0        # optional, interface to listen on, default 0 for all.
  port 162            # optional, port to listen for traps, default is 162
  out_executor lib/snmp_out_exec.rb # Threat traffic plugin
  # out_executor lib/snmp_out_exec_all.rb # All traffic plugin
  tag palo.snmp  # optional, tag to assign to events, default is alert.snmptrap
</source>

<source>
  type snmp
  tag snmp.server1
  nodes name, value
  out_executor lib/snmp_get_out_exec.rb
  host 192.168.0.254 # target ip address
  port 161 # target port
  community public # community
  version :SNMPv2c
  mib 1.3.6.1.2.1.25.3.3.1.2.1, 1.3.6.1.2.1.25.3.3.1.2.2, 1.3.6.1.2.1.99.1.1.1.4.1, 1.3.6.1.2.1.99.1.1.1.4.3 # mibs are comma seperated
  method_type get
  polling_time 1
  polling_type async_run
</source>
````

#### Run fluentd

````bash
 fluentd -c config/fluentd/td-agent.conf -d fluent.pid
````

### [5:nginx](http://wiki.nginx.org/Install#Official_Red_Hat.2FCentOS_packages)
````bash
cat <<EOF> /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/x86_64/
gpgcheck=0
enabled=1
EOF
yum install --enablerepo=nginx nginx -y
cp -p /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.org
cp -p ./config/nginx/conf.d/.htpasswd /etc/nginx/conf.d/.htpasswd
\cp -pf ./config/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
systemctl start nginx.service
````

#### Confirmation

Visit __http://"PALallaxIP"__

### 6:Tips

- Default user/password for basic authentication for kibana4 is "admin"/"admin"
- If SELinux is Enforcing Setting, it may fail to proxy\_path from NGINX to KIBANA. Allow proxy\_path, or please disable/permissive the SELinux.
- Increase the file descriptors (FD) value.

	Edit the following files.

	> /etc/security/limits.conf

	Example:
	root soft nofile 65535
	root hard nofile 65535


- deletion of index is possible in "curator"

	Example:

	The following is the command to delete all index .

	>$ curator delete indices --all-indices

	Please see below for details.
	https://www.elastic.co/guide/en/elasticsearch/client/curator/current/index.html

## License

PALallax is released under the Apache License version 2.0
- [http://www.apache.org/licenses/LICENSE-2.0.html](http://www.apache.org/licenses/LICENSE-2.0.html)

__By downloading PALallax, you agree to be bound by the terms of the license below.__
- [http://www.ap-com.co.jp/ja/paloalto/palallax/consent.html](http://www.ap-com.co.jp/ja/paloalto/palallax/consent.html)

## Contact Us

Inquiries about PALallax, please e-mail to [unite@ap-com.co.jp](mailto:unite@ap-com.co.jp) .
