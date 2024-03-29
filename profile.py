import geni.portal as portal
import geni.rspec.pg as RSpec
import geni.rspec.igext

pc = portal.Context()

pc.defineParameter("hadoop_ver", "Hadoop version", portal.ParameterType.STRING, "3.3.6")

pc.defineParameter("ha", "whether use HA mode", portal.ParameterType.BOOLEAN, False)

pc.defineParameter("num_dns", "Number of datanodes", portal.ParameterType.INTEGER, 3)

pc.defineParameter("num_clients", "Number of client nodes", portal.ParameterType.INTEGER, 2)

pc.defineParameter("raw", "Use physical nodes", portal.ParameterType.BOOLEAN, True)

pc.defineParameter("phystype", "Node type for all nodes", portal.ParameterType.STRING, "")
		    
pc.defineParameter( "linkSpeed", "Link Speed", portal.ParameterType.INTEGER, 10000000,
                    [(0,"Any"), (100000, "100Mb/s"), (1000000, "1Gb/s"), (10000000, "10Gb/s"), (25000000, "25Gb/s"), (100000000, "100Gb/s")])

pc.defineParameter("cfg", "Auto config", portal.ParameterType.BOOLEAN, True)

# advanced settings

pc.defineParameter("mem", "Memory per VM", portal.ParameterType.INTEGER, 1024, advanced=True)

pc.defineParameter("cores", "CPU cores per VM", portal.ParameterType.INTEGER, 16, advanced=True)

params = pc.bindParameters()
rspec = RSpec.Request()
lan = RSpec.LAN()
lan.bandwidth = params.linkSpeed
rspec.addResource(lan)
nodes = []

IMAGE = "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU22-64-STD"
# SETUP = "https://archive.apache.org/dist/hadoop/core/hadoop-3.3.6/hadoop-3.3.6.tar.gz"
HADOOP = "https://archive.apache.org/dist/hadoop/core/hadoop-{}/hadoop-{}.tar.gz".format(params.hadoop_ver, params.hadoop_ver)
ZOOKEEPER = "https://dlcdn.apache.org/zookeeper/zookeeper-3.9.2/apache-zookeeper-3.9.2-bin.tar.gz"


def configNode(name, public, raw, phystype):
    if raw:
        node = RSpec.RawPC(name)
    else:
        node = geni.rspec.igext.XenVM(name)
        node.ram = params.mem
        node.cores = params.cores
        node.exclusive = True
        if public:
            node.routable_control_ip = True
    if phystype != "":
        node.hardware_type = phystype
    node.disk_image = IMAGE
    # node.addService(RSpec.Execute("sh", "sudo bash /local/repository/init.sh"))
    node.addService(RSpec.Install(HADOOP, "/users/jason92/"))
    if params.ha:
        if params.cfg:
            node.addService(RSpec.Execute("sh", "sudo bash /local/repository/hadoop/ha/config_hadoop.sh {}".format(params.hadoop_ver)))
        else:
            node.addService(RSpec.Execute("sh", "sudo cp /local/repository/hadoop/ha/config_hadoop.sh /users/jason92/"))
    else:
        if params.cfg:
            node.addService(RSpec.Execute("sh", "sudo bash /local/repository/hadoop/config.sh {}".format(params.hadoop_ver)))
        else:
            node.addService(RSpec.Execute("sh", "sudo cp /local/repository/hadoop/config.sh /users/jason92"))
    node.addService(RSpec.Execute("sh", "sudo bash /local/repository/init.sh"))
    node.addService(RSpec.Execute("sh", "sudo bash /local/repository/init.sh"))
    nodes.append(node)
    return node

if params.ha:
    num_nns = 2
    num_jns = 3
else:
    num_nns = 1
    num_jns = 0

# config namenodes
for i in range(num_nns):
    node = configNode("nn" + str(i + 1), True, params.raw, params.phystype)

# config journalnodes
for i in range(num_jns):
    node = configNode("jn" + str(i + 1), True, params.raw, params.phystype)
    if params.ha:
        node.addService(RSpec.Install(ZOOKEEPER, "/users/jason92"))
        if params.cfg:
            node.addService(RSpec.Execute("sh", "sudo bash /local/repository/hadoop/ha/config_zookeeper.sh {}".format(i + 1)))
        else:
            node.addService(RSpec.Execute("sh", "sudo cp /local/repository/hadoop/ha/config_zookeeper.sh /users/jason92"))


# config datanodes
for i in range(params.num_dns):
    node = configNode("dn" + str(i + 1), False, params.raw, params.phystype)

# config client nodes
for i in range(params.num_clients):
    node = configNode("client" + str(i + 1), False, params.raw, params.phystype)

# finalize
for node in nodes:
    iface = node.addInterface("if0")
    lan.addInterface(iface)
    rspec.addResource(node)

from lxml import etree as ET

tour = geni.rspec.igext.Tour()
tour.Description( geni.rspec.igext.Tour.TEXT, "A cluster with hadoop deployed")
rspec.addTour( tour )

pc.printRequestRSpec( rspec )
