import os
import boto3
import json
from botocore.exceptions import ClientError

def get_regions(client):
  """ Build a region list """
  reg_list = []
  regions = client.describe_regions()
  data_str = json.dumps(regions)
  resp = json.loads(data_str)
  region_str = json.dumps(resp['Regions'])
  region = json.loads(region_str)
  for reg in region:
    reg_list.append(reg['RegionName'])
  return reg_list

def get_default_vpcs(client):
  """ Get default VPCs """
  vpc_list = []
  vpcs = client.describe_vpcs(
    Filters=[
      {
          'Name' : 'isDefault',
          'Values' : [
            'true',
          ],
      },
    ]
  )
  vpcs_str = json.dumps(vpcs)
  resp = json.loads(vpcs_str)
  data = json.dumps(resp['Vpcs'])
  vpcs = json.loads(data)

  for vpc in vpcs:
    vpc_list.append(vpc['VpcId'])

  return vpc_list

def delete_vpc_igws(ec2, vpcid):
  """ Detach and delete all internet gateways in a VPC """
  vpc_resource = ec2.Vpc(vpcid)
  igws = vpc_resource.internet_gateways.all()
  if igws:
    for igw in igws:
      try:
        print("==> Detaching and Removing igw-id: ", igw.id)
        igw.detach_from_vpc(
          VpcId=vpcid
        )
        igw.delete(
        )
      except boto3.exceptions.Boto3Error as e:
        print(e)

def delete_vpc_subnets(ec2, vpcid):
  """ Delete all subnets in a VPC's """
  vpc_resource = ec2.Vpc(vpcid)
  subnets = vpc_resource.subnets.all()
  default_subnets = [ec2.Subnet(subnet.id) for subnet in subnets if subnet.default_for_az]

  if default_subnets:
    try:
      for sub in default_subnets:
        print("==> Removing sub-id: ", sub.id)
        sub.delete(
        )
    except boto3.exceptions.Boto3Error as e:
      print(e)

def delete_vpc_route_tables(ec2, vpcid):
  """ Delete all route tables in a VPC """
  vpc_resource = ec2.Vpc(vpcid)
  rtbs = vpc_resource.route_tables.all()
  if rtbs:
    try:
      for rtb in rtbs:
        assoc_attr = [rtb.associations_attribute for rtb in rtbs]
        if [rtb_ass[0]['RouteTableId'] for rtb_ass in assoc_attr if rtb_ass[0]['Main'] == True]:
          print("==> " + rtb.id + " is the main route table, continue...")
          continue
        print("==> Removing rtb-id: ", rtb.id)
        table = ec2.RouteTable(rtb.id)
        table.delete()
    except boto3.exceptions.Boto3Error as e:
      print(e)

def delete_vpc_acls(ec2, vpcid):
  """ Delete all ACLs in a VPC """

  vpc_resource = ec2.Vpc(vpcid)
  acls = vpc_resource.network_acls.all()

  if acls:
    try:
      for acl in acls:
        if acl.is_default:
          print("==> " + acl.id + " is the default NACL, continue...")
          continue
        print("==> Removing acl-id: ", acl.id)
        acl.delete()
    except boto3.exceptions.Boto3Error as e:
      print(e)

def delete_vpc_security_groups(ec2, vpcid):
  """ Delete all security groups in a VPC """
  vpc_resource = ec2.Vpc(vpcid)
  sgps = vpc_resource.security_groups.all()
  if sgps:
    try:
      for sg in sgps:
        if sg.group_name == 'default':
          print("==> " + sg.id + " is the default security group, continue...")
          continue
        print("==> Removing sg-id: ", sg.id)
        sg.delete(
        )
    except boto3.exceptions.Boto3Error as e:
      print(e)

def delete_vpc(ec2, vpcid):
  """ Delete a VPC """
  vpc_resource = ec2.Vpc(vpcid)
  try:
    print("==> Removing vpc-id: ", vpc_resource.id)
    vpc_resource.delete(
    )
  except boto3.exceptions.Boto3Error as e:
      print(e)
      print("[!] Please remove dependencies and delete VPC manually.")

def lambda_handler(event, context):
    client = boto3.client('ec2')
    regions = get_regions(client)
    print("==> Regions found:")
    print(regions)

    try:
        try:
            for region in regions:
              vpc_client = boto3.client('ec2', region_name = region)
              ec2 = boto3.resource('ec2', region_name = region)
              vpcs = get_default_vpcs(vpc_client)
              print("==> Default VPCs in " + region + ":")
              print(vpcs)
              for vpc in vpcs:
                print("\n" + "\n" + "REGION:" + region + "\n" + "VPC Id:" + vpc)
                delete_vpc_igws(ec2, vpc)
                delete_vpc_subnets(ec2, vpc)
                delete_vpc_route_tables(ec2, vpc)
                delete_vpc_acls(ec2, vpc)
                delete_vpc_security_groups(ec2, vpc)
                delete_vpc(ec2, vpc)
        except ClientError as e:
          print("Unexpected Error:", e)
          errorText = e.response['Error']['Message']
          print("Error Text: ", errorText)
          pass
    except ClientError as e:
        print(e.message)
        FinalMsg = e.message
