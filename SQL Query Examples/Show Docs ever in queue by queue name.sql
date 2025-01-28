/*********************************
Query: INOW Show Docs ever in queue by queue name.sql
Usage: Set the queue name and queue start time range
Created: 05-14-2024 by Casey Callahan
	Specific for MSSQL. 
	Will return documents that have ever entered the queue.
	Properly converts local time to UTC for query parameters then back to local time in result set.
	Documents can possibly enter a queue multiple times so may have mutliple results. Sorted for oldest to newest start time in queue.

************************************/

/*** Initialize & set variables ***/
declare @searchQueue varchar(128) = 'ADM_Verified Documents' --enter workflow queue name here
declare @qStartTimeLB datetime = '2019-01-01 00:00:00' --set start of date/time range you're searching
declare @qStartTimeUB datetime = '2024-04-01 00:00:00' --set ending of date/time range you're searching


/******** main query with conversion variables ***************/
--Change time from user time zone to UTC so query is bounded by correctly assuming you are in US Eastern time zone
declare @qStartUtcLB datetime = convert(Datetime, @qStartTimeLB AT TIME ZONE 'Eastern Standard Time' AT TIME ZONE 'UTC')
declare @qStartUtcUB datetime = convert(Datetime, @qStartTimeUB AT TIME ZONE 'Eastern Standard Time' AT TIME ZONE 'UTC')

--We order by doc id and SEQ_Num since a document can possibly be in a queue more than once. Since this is the case a document can return multiple results in the query.
select a.Archived, a.ITEM_ID, a.SEQ_NUM, convert(Datetime, a.START_TIME AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') [queue_start_time_local], convert(Datetime, a.FINISH_TIME AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') [queue_finish_time_local]  
	, a.QUEUE_NAME, a.DOC_ID, a.FOLDER, a.tab, a.f3, a.f4, a.f5, a.DRAWER_NAME, a.DOC_TYPE_NAME
from (
	select '' as [Archived], wfiqh.ITEM_ID, wfiqh.SEQ_NUM, wfiqh.START_TIME, wfiqh.FINISH_TIME, wfq.QUEUE_NAME
		, id.DOC_ID, id.folder, id.tab, id.f3, id.f4,id.f5, idr.DRAWER_NAME, idt.DOC_TYPE_NAME
	from inuser.IN_WF_ITEM_QUEUE_HIST wfiqh
	inner join inuser.in_wf_queue wfq on wfiqh.QUEUE_ID = wfq.QUEUE_ID
	inner join inuser.in_wf_item wfi on wfiqh.ITEM_ID = wfi.ITEM_ID
	inner join inuser.in_doc id on wfi.OBJ_ID = id.DOC_ID
	inner join inuser.in_drawer idr on id.DRAWER_ID = idr.DRAWER_ID
	inner join inuser.IN_DOC_TYPE idt on id.DOC_TYPE_ID = idt. DOC_TYPE_ID
	where 
	wfq.queue_name = @searchQueue
	and wfiqh.START_TIME >= @qStartUtcLB and  wfiqh.START_TIME <= @qStartUtcUB
	UNION
	select 'Y' as [Archived], wfiqha.ITEM_ID, wfiqha.SEQ_NUM, wfiqha.START_TIME, wfiqha.FINISH_TIME,wfq.QUEUE_NAME
		, id.DOC_ID, id.folder, id.tab, id.f3, id.f4,id.f5, idr.DRAWER_NAME, idt.DOC_TYPE_NAME
	from inuser.IN_WF_ITEM_QUEUE_HIST_ARCH wfiqha
	inner join inuser.in_wf_queue wfq on wfiqha.QUEUE_ID = wfq.QUEUE_ID
	inner join inuser.in_wf_item_arch wfia on wfiqha.ITEM_ID = wfia.ITEM_ID
	inner join inuser.in_doc id on wfia.OBJ_ID = id.DOC_ID
	inner join inuser.in_drawer idr on id.DRAWER_ID = idr.DRAWER_ID
	inner join inuser.IN_DOC_TYPE idt on id.DOC_TYPE_ID = idt. DOC_TYPE_ID
	where 
	wfq.queue_name = @searchQueue
	and wfiqha.START_TIME >= @qStartUtcLB and  wfiqha.START_TIME <= @qStartUtcUB
) a
order by DOC_ID, Archived, ITEM_ID, SEQ_NUM
