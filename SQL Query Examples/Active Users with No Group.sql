/*
Perceptive Content Active User List with NO Group Membership
Last Updated: 8/22/2019

NOTES: Filters out the following users:
	- Manager/owner users
	- OFA TransForm Service Account (inIntegrationtSvc)
	- Invalid Accounts (New User and LNAME, FNAME)
*/

--create temp working table for group access listing
if object_id('tempdb..#usr_accesslist') is not null
	drop table #usr_accesslist
GO

--populate temp table
select * into #usr_accesslist from (
	select sgm.usr_id as sgm_usr_id
		, scg.group_id as scg_group_id
		, scg.group_name as scg_group_name
	from inuser.in_sc_group_member sgm 
	left join inuser.in_sc_group scg on
		sgm.group_id = scg.group_id
) as data


select DISTINCT scu.usr_id, scu.usr_last_name, scu.usr_first_name, scu.usr_name, scu.MOBILE_NUM, scu.usr_cat, 
scu.is_deleted, scu.IS_ACTIVE, data.groups
from inuser.IN_SC_USR scu
left join (
			SELECT distinct
				sgm_usr_id,
				stuff ( ( SELECT
							  ', ' + cast(scg_Group_Name as varchar(max))
							FROM
							#usr_accesslist tableA_1
							where tableA_1.sgm_usr_id = tableA_2.sgm_usr_id
							FOR XML PATH ( '' ) ) , 1 , 2 , '' ) as groups
			from #usr_accesslist tableA_2 
			) as data 
			on data.sgm_usr_id = scu.usr_id
where IS_ACTIVE = 1 and IS_DELETED = 0 and usr_cat = 0 and data.groups is null
	and scu.usr_id NOT IN (SELECT entity_id FROM inuser.in_sc_priv WHERE priv_id IN (2501,6500)) -- 2501 is the manager privilege, 6500 is owner privilege
	and usr_name NOT IN ('inIntegrationtSvc') -- How to capture this programmatically?
	and scu.usr_id NOT IN (
		'301YX19_005D6VWMY0018K2', -- New User
		'301YW7L_004HXSG9Z00019T', -- LNAME, FNAME
		'321Z4B5_075BS8VW0000HFE'  -- USR_LAST_NAME, USR_FIRST_NAME
	)
order by usr_last_name,usr_first_name