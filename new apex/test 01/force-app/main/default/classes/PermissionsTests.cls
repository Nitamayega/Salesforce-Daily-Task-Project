@IsTest
private class PermissionsTests {

    @IsTest
    static void testPositivePermissionSet() {
        // 1) Siapkan 2 user (owner & accessor)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User owner = new User(
            Alias='own1', Email='own1@example.com',
            Username='own1+' + System.currentTimeMillis() + '@example.com',
            LastName='Owner', TimeZoneSidKey='Asia/Jakarta',
            LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US', ProfileId=p.Id
        );
        insert owner;

        User accessor = new User(
            Alias='acc1', Email='acc1@example.com',
            Username='acc1+' + System.currentTimeMillis() + '@example.com',
            LastName='Accessor', TimeZoneSidKey='Asia/Jakarta',
            LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US', ProfileId=p.Id
        );
        insert accessor;

        // 2) Buat record Private_Object__c dimiliki oleh 'owner'
        Private_Object__c po = new Private_Object__c(Name='Test PO');
        po.OwnerId = owner.Id;
        insert po;

        // 3) Assign Permission Set ke 'accessor'
        PermissionSet ps = [
            SELECT Id FROM PermissionSet WHERE Name = 'Private_Object_Access' LIMIT 1
        ];
        insert new PermissionSetAssignment(AssigneeId = accessor.Id, PermissionSetId = ps.Id);

        Test.startTest();
        // 4) Jalankan sebagai accessor, pastikan ia bisa melihat record milik orang lain
        System.runAs(accessor){
            // Query langsung by Id; jika tidak punya akses, hasilnya 0 atau QueryException
            Private_Object__c seen = [SELECT Id, Name FROM Private_Object__c WHERE Id = :po.Id LIMIT 1];
            System.assertNotEquals(null, seen, 'Accessor should be able to view the Private_Object__c record they do not own.');
        }
        Test.stopTest();
    }
}