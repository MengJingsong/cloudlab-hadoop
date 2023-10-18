import geni.portal as portal
import geni.rspec.pg as RSpec
import geni.rspec.igext

pc = portal.Context()

pc.defineParameter( "n", "Number of slave nodes",
		    portal.ParameterType.INTEGER, 3 )

pc.defineParameter( "raw", "Use physical nodes",
                    portal.ParameterType.BOOLEAN, False )

pc.defineParameter( "mem", "Memory per VM",
		    portal.ParameterType.INTEGER, 256 )
		    
pc.defineParameter( "linkSpeed", "Link Speed", portal.ParameterType.INTEGER, 0,
                    [(0,"Any"), (100000, "100Mb/s"), (1000000, "1Gb/s"), (10000000, "10Gb/s"), (25000000, "25Gb/s"), (100000000, "100Gb/s")])
                    
pc.defineParameter( "phystype", "Optional physical node type", portal.ParameterType.STRING, "", 
                    longDescription="Specify a single physical node type (pc3000, d710, etc) instead of letting the resource mapper choose for you")

params = pc.bindParameters()

IMAGE = "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU22-64-STD"
SETUP = "https://archive.apache.org/dist/hadoop/core/hadoop-3.3.6/hadoop-3.3.6.tar.gz"

rspec = RSpec.Request()

lan = RSpec.LAN()
lan.bandwidth = params.linkSpeed
rspec.addResource( lan )

def Config( name, public):
    if params.raw:
        node = RSpec.RawPC( name )
    else:
        node = geni.rspec.igext.XenVM( name )
        node.ram = params.mem
        if public:
            node.routable_control_ip = True
    if params.phystype != "":
        node.hardware_type = phystype
    node.disk_image = IMAGE
    # node.addService(RSpec.Install( SETUP, "/tmp"))
    # node.addService(RSpec.Execute( "sh", "sudo bash /local/repository/script.sh"))
    iface = node.addInterface("if0")
    lan.addInterface(iface)
    rspec.addResource(node)

Config("namenode", True)
Config("resourcemanager", True)

for i in range( params.n ):
    Config("slave" + str( i ), False)

from lxml import etree as ET

tour = geni.rspec.igext.Tour()
tour.Description( geni.rspec.igext.Tour.TEXT, "A cluster will run Hadoop 3.3.6. It includes a name node, a resource manager, and as many slaves as you choose." )
# tour.Instructions( geni.rspec.igext.Tour.MARKDOWN, "After your instance boots (approx. 5-10 minutes), you can log into the resource manager node and submit jobs.  [The HDFS web UI](http://{host-namenode}:50070/) and [the resource manager UI](http://{host-resourcemanager}:8088/) are running but enable NO authentication mechanism by default and therefore are NOT remotely accessible; please use secure channels (e.g., ssh port forwarding or turn on Hadoop Kerberos) if you need to access them." )
rspec.addTour( tour )

pc.printRequestRSpec( rspec )
