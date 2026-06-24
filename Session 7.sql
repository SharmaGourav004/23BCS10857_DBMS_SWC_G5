--Q1-----------------------------------------------------------------------------------------
SELECT COUNT(*) AS active_pages
FROM (
    SELECT DISTINCT ON (page_id)
        page_id,
        status
    FROM page_status_log
    ORDER BY page_id, changed_at DESC, event_id DESC
) latest
WHERE status = 'active';


--Q2----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_positive_ad_channel()
RETURNS TABLE(
    advertising_channel TEXT,
    max_yearly_spending BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH channel_stats AS (
        SELECT 
            ua.advertising_channel,
            MAX(ua.money_spent) AS max_yearly_spending
        FROM uber_advertising ua
        GROUP BY ua.advertising_channel
        HAVING MIN(ua.customers_acquired) > 1500
    )
    SELECT 
        cs.advertising_channel,
        cs.max_yearly_spending
    FROM channel_stats cs
    ORDER BY cs.max_yearly_spending
    LIMIT 1;
END;
$$;
