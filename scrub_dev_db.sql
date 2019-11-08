INSERT INTO toggles (feature_name, description) VALUES ('API_MAINTENANCE_MODE', 'REMOVE AFTER MAINTENANCE RELEASE');
INSERT INTO toggles (feature_name, description) VALUES ('WEB_MAINTENANCE_MODE', 'REMOVE AFTER MAINTENANCE RELEASE');
INSERT INTO toggles (feature_name, description) VALUES ('SYNC_MAINTENANCE_MODE', 'REMOVE AFTER MAINTENANCE RELEASE');

update sales_channels set active=0;
update warehouses set active = 0;
update companies set company_status_id=3 where company_id not in (1,2);
update warehouse_scheduled_jobs set active=0, next_attempt=Date('9999-12-31 23:59:59');
update company_jobs set next_attempt=Date('9999-12-31 23:59:59');
update sales_channel_jobs set next_attempt=Date('9999-12-31 23:59:59');

UPDATE companies a join companies b using(company_id)
SET a.notification_channel=concat( 'fake_', b.notification_channel);

UPDATE companies a join companies b using(company_id)
SET a.contact_email=concat( 'fake_', b.contact_email)
where company_id not in (1,2);


UPDATE vendors a join vendors b using(vendor_id)
SET a.contact_email=concat( 'fake_', b.contact_email),
a.po_email=concat( 'fake_', b.po_email);


update company_payment_methods set description='FakeCard - 0000';


UPDATE company_payment_method_stripe_cards a join company_payment_method_stripe_cards b using(method_id)
SET a.card_id=concat( 'fake_', b.card_id),
    a.fingerPrint= concat( 'fake_', b.fingerPrint),
    a.last4= '0000',
    a.brand= 'FakeVisa',
	a.expire_month= 01,
    a.expire_year= 1900;


UPDATE company_payment_stripe_charge a join company_payment_stripe_charge b using(payment_id)
SET a.charge_id=concat( 'fake_', b.charge_id),
    a.customer_id= concat( 'fake_', b.customer_id),
    a.source_id= concat( 'fake_', b.source_id);
	
	
UPDATE shipping_provider_account_params a join shipping_provider_account_params b using(provider_account_id)
SET a.param_name=concat( 'fake_', b.param_name),
    a.param_value= concat( 'fake_', b.param_value);
	
	
update warehouse_comm_settings 
set login_server='login_server disabled for QA replica DB', 
login_user='login_user disabled for QA replica DB', 
login_password = 'login_password disabled for QA replica DB';


update users set api_admin = 1;

update apps set app_status_id = 1 where app_identifier = 'skubana';

update users set enabled = 1 where email like 'arnau%@skubana.com';

UPDATE customer_emails a join customer_emails b using(customer_email_id)
SET a.email=concat( 'fake_', b.email);

update company_contacts set email=concat( 'fake_', email);

insert into users(company_id,user_status_id,enabled,user_role_id,email,user_password,user_name,created,account_management,user_administration,marketplaces,warehouses,suppliers,products,inventory,purchase_orders,orderbots,customer_orders,templates,shipping,reporting,listings,repricing,api_access,security_question_id,security_question_answer,workstation_access_only,shipping_providers,accounting,customers,po_authorizer,api_admin)
values (2,1,1,1,'arnaud+dev1@skubana.com','1302d1492430775be46945151222919507dfc31d4b1a1ec62fbd227e76ad37913f297c818d7445e1','Arnaud B',now(),1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,'pf',0,1,1,1,1,1);

insert into users(company_id,user_status_id,enabled,user_role_id,email,user_password,user_name,created,account_management,user_administration,marketplaces,warehouses,suppliers,products,inventory,purchase_orders,orderbots,customer_orders,templates,shipping,reporting,listings,repricing,api_access,security_question_id,security_question_answer,workstation_access_only,shipping_providers,accounting,customers,po_authorizer,api_admin)
values (2,1,1,1,'perry+dev1@skubana.com','1302d1492430775be46945151222919507dfc31d4b1a1ec62fbd227e76ad37913f297c818d7445e1','hager el mahjoub',now(),1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,'rinat',0,1,1,1,1,1);

insert into users(company_id,user_status_id,enabled,user_role_id,email,user_password,user_name,created,account_management,user_administration,marketplaces,warehouses,suppliers,products,inventory,purchase_orders,orderbots,customer_orders,templates,shipping,reporting,listings,repricing,api_access,security_question_id,security_question_answer,workstation_access_only,shipping_providers,accounting,customers,po_authorizer,api_admin)
values (2,1,1,1,'daniel+dev1@skubana.com','1302d1492430775be46945151222919507dfc31d4b1a1ec62fbd227e76ad37913f297c818d7445e1','hager el mahjoub',now(),1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,'rinat',0,1,1,1,1,1);

insert into users(company_id,user_status_id,enabled,user_role_id,email,user_password,user_name,created,account_management,user_administration,marketplaces,warehouses,suppliers,products,inventory,purchase_orders,orderbots,customer_orders,templates,shipping,reporting,listings,repricing,api_access,security_question_id,security_question_answer,workstation_access_only,shipping_providers,accounting,customers,po_authorizer,api_admin)
values (2,1,1,1,'daniel+devlogin@skubana.com','afb289650d5c234c00f609ad8eb26cb3252902e7d9d72aa85ff46e4a5bcb5800ca97233c65157f7d','hager el mahjoub',now(),1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,'rinat',0,1,1,1,1,1);

insert into users(company_id,user_status_id,enabled,user_role_id,email,user_password,user_name,created,account_management,user_administration,marketplaces,warehouses,suppliers,products,inventory,purchase_orders,orderbots,customer_orders,templates,shipping,reporting,listings,repricing,api_access,security_question_id,security_question_answer,workstation_access_only,shipping_providers,accounting,customers,po_authorizer,api_admin)
values (2,1,1,1,'neesha+devlogin@skubana.com','afb289650d5c234c00f609ad8eb26cb3252902e7d9d72aa85ff46e4a5bcb5800ca97233c65157f7d','hager el mahjoub',now(),1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,'rinat',0,1,1,1,1,1);

insert into users(company_id,user_status_id,enabled,user_role_id,email,user_password,user_name,created,account_management,user_administration,marketplaces,warehouses,suppliers,products,inventory,purchase_orders,orderbots,customer_orders,templates,shipping,reporting,listings,repricing,api_access,security_question_id,security_question_answer,workstation_access_only,shipping_providers,accounting,customers,po_authorizer,api_admin)
values (2,1,1,1,'seth.abrams+devlogin@skubana.com','afb289650d5c234c00f609ad8eb26cb3252902e7d9d72aa85ff46e4a5bcb5800ca97233c65157f7d','hager el mahjoub',now(),1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,'rinat',0,1,1,1,1,1);

insert into users(company_id,user_status_id,enabled,user_role_id,email,user_password,user_name,created,account_management,user_administration,marketplaces,warehouses,suppliers,products,inventory,purchase_orders,orderbots,customer_orders,templates,shipping,reporting,listings,repricing,api_access,security_question_id,security_question_answer,workstation_access_only,shipping_providers,accounting,customers,po_authorizer,api_admin)
values (2,1,1,1,'bosco+dev1@skubana.com','1302d1492430775be46945151222919507dfc31d4b1a1ec62fbd227e76ad37913f297c818d7445e1','hager el mahjoub',now(),1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,'rinat',0,1,1,1,1,1);

insert into users(company_id,user_status_id,enabled,user_role_id,email,user_password,user_name,created,account_management,user_administration,marketplaces,warehouses,suppliers,products,inventory,purchase_orders,orderbots,customer_orders,templates,shipping,reporting,listings,repricing,api_access,security_question_id,security_question_answer,workstation_access_only,shipping_providers,accounting,customers,po_authorizer,api_admin)
values (2,1,1,1,'peter.jasko+devlogin@skubana.com','afb289650d5c234c00f609ad8eb26cb3252902e7d9d72aa85ff46e4a5bcb5800ca97233c65157f7d','hager el mahjoub',now(),1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,'rinat',0,1,1,1,1,1);