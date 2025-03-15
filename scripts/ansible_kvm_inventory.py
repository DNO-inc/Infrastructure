#!/usr/bin/env python

import json
import subprocess

terraform_outputs = json.loads(
    subprocess.check_output(
        "terraform -chdir=terraform/kvm output -json".split(" ")
    )
)

ips_object = terraform_outputs["vm_ips"]["value"]

inventory = {
    "all": {
        "hosts": list(ips_object.values())
    },
    **{k: {"hosts": [v]} for k, v in ips_object.items()}
}

print(
    json.dumps(inventory, indent=2)
)
