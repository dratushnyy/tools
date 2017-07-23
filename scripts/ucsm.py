import ssl
import subprocess
from UcsSdk import *
from tabulate import tabulate

# code based on UCSM SDK 0.8.3

# http://stackoverflow.com/questions/27835619/ssl-certificate-verify-failed-error
if hasattr(ssl, '_create_unverified_context'):
    ssl._create_default_https_context = ssl._create_unverified_context


def GetJavaInstallationPath():
    path = subprocess.check_output(['which', 'javaws'])
    if not path:
        raise Exception(
            "Please make sure JAVA is installed and javaws is available.")
    path = path.strip()
    return path


# monkeypatch for ucsm GetJavaInstallationPath for Mac OSx
if hasattr(UcsUtils, 'GetJavaInstallationPath'):
    if platform.system() == 'Darwin':
        UcsUtils.GetJavaInstallationPath = staticmethod(GetJavaInstallationPath)


class UCSM(object):
    def __init__(self, ip, user_name, password, sub_org=None, dump_xml=False):
        self.ip = ip
        self.user_name = user_name
        self.password = password
        self.handle = UcsHandle()
        self.handle.Login(self.ip,
                          username=self.user_name,
                          password=self.password,
                          noSsl=False, port=443,
                          dumpXml=YesOrNo.FALSE)
        self.blades = []
        self.rack_units = []
        if sub_org:
            self.sub_org = "org-{}".format(sub_org)
        self.servers = []
        self.dump_xml = dump_xml
        self.vnic_templates = []

    def __del__(self):
        self.handle.Logout()

    def show_gui(self):
        self.handle.StartGuiSession()

    def get_blades_and_racks(self):
        self.blades = self.handle.GetManagedObject(
            None, ComputeBlade.ClassId())
        self.rack_units = self.handle.GetManagedObject(
            None, ComputeRackUnit.ClassId())

    def run_kvm_for(self, srv):
        self.handle.StartKvmSession(blade=srv, frameTitle=srv.__dict__['Dn'],
                                    dumpXml=self.dump_xml)

    def run_kvms(self):
        for blade in self.blades:
            self.run_kvm_for(blade)

        for rack_unit in self.rack_units:
            self.run_kvm_for(rack_unit)

    def get_org_root(self):
        if self.sub_org:
            root_dn = "org-root/{}".format(self.sub_org)
        else:
            root_dn = "org-root"
        root_obj = self.handle.GetManagedObject(None, OrgOrg.ClassId(),
                                                {OrgOrg.DN: root_dn},
                                                dumpXml=self.dump_xml)[0]
        return root_obj

    def get_servers(self):
        root_obj = self.get_org_root()
        self.servers = self.handle.GetManagedObject(root_obj,
                                                    LsServer.ClassId())

    def get_vnics_and_vlans(self, skip_sriov=True):
        for server in self.servers:
            if server.AssocState == 'associated':
                print ("{}".format(str(server.Name)).center(20))
                print('-'*20)
                vnics = self.handle.ConfigResolveChildren(VnicEther.ClassId(),
                                                          server.Dn, None,
                                                          YesOrNo.TRUE)
                vnic_data = []
                for vnic in vnics.OutConfigs.GetChild():
                    if vnic.VirtualizationPreference == "SRIOV-VMFEX" \
                            and skip_sriov:
                        continue
                    vnic_ifs = self.handle.ConfigResolveChildren(
                        VnicEtherIf.ClassId(), vnic.Dn, None, YesOrNo.TRUE)
                    for vnic_if in vnic_ifs.OutConfigs.GetChild():
                         vnic_data.append([vnic.Name, vnic_if.Vnet])
                print tabulate(vnic_data, headers=["vNic", "VLAN"])
                print("\n")

    def get_vnic_templates(self):
        root_obj = self.get_org_root()
        templates = self.handle.GetManagedObject(root_obj,
                                                 VnicLanConnTempl.ClassId())
        for template in templates:
            template_ifs = self.handle.ConfigResolveChildren(
                VnicEtherIf.ClassId(), template.Dn, None, YesOrNo.TRUE)
            print template
            for template_if in template_ifs.OutConfigs.GetChild():
                vlan_name = template_if.Name
                vlan = self.handle.GetManagedObject(None, FabricVlan.ClassId(),
                                                    {"Name": vlan_name})[0]
                print vlan.Id

    def get_service_profile_circuit(self):
        chassis = self.handle.GetManagedObject(None,
                                               EquipmentChassis.ClassId())
        blades = self.handle.GetManagedObject(chassis, ComputeBlade.ClassId())
        fis = self.handle.GetManagedObject(blades, FabricLocale.ClassId())
        fabric_paths = self.handle.GetManagedObject(fis, FabricPath.ClassId())
        circuits = self.handle.GetManagedObject(fabric_paths, DcxVc.ClassId())
        for circuit in circuits:
            print circuit.Id, circuit.Vnic, circuit.LinkState, circuit.SwitchId

    def get_data(self):
        self.get_servers()
        self.get_blades_and_racks()