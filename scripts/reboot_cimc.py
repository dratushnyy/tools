import argparse
import multiprocessing
import time
from imcsdk.imchandle import ImcHandle
from imcsdk.mometa.compute import ComputeRackUnit

WAIT_TIMEOUT = 360


def reboot(cimc_ip, cimc_user, cimc_password):
    handle = ImcHandle(cimc_ip, cimc_user, cimc_password)
    handle.login(auto_refresh=False)
    mo = handle.config_resolve_dn("sys/rack-unit-1")
    mo.admin_power = ComputeRackUnit.ADMIN_POWER_BMC_RESET_IMMEDIATE
    try:
        handle.set_mo(mo)
        # handle.set_imc_managedobject(
        #     mo, class_id="ComputeRackUnit",
        #     params={
        #         ComputeRackUnit.ADMIN_POWER:
        #             ComputeRackUnit.CONST_ADMIN_POWER_BMC_RESET_IMMEDIATE,
        #         ComputeRackUnit.DN: "sys/rack-unit-1"})
    except Exception as e:
        print(e)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("cimc_ip", type=str)
    parser.add_argument("cimc_user", type=str)
    parser.add_argument("cimc_password", type=str)
    args = parser.parse_args()
    p = multiprocessing.Process(target=reboot,
                                args=(args.cimc_ip,
                                      args.cimc_user, args.cimc_password),
                                name='reboot_cimc')
    p.start()
    time.sleep(WAIT_TIMEOUT)
    if p.is_alive():
        p.terminate()
        p.join()