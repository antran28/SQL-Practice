SELECT COUNT(device_type)
  FILTER (WHERE device_type = 'laptop')
  AS laptop_views,
  
COUNT(device_type)
  FILTER (WHERE device_type = 'phone' OR device_type = 'tablet')
  AS mobile_views
  FROM viewership;
