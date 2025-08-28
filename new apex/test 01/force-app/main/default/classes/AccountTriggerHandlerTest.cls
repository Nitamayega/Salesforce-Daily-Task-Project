@IsTest
private class AccountTriggerHandlerTest {

    /* ---------- helpers ---------- */

    // Pick any active Industry that is not used by any Account yet.
    private static String pickUnusedIndustry() {
        Set<String> used = new Set<String>();
        for (AggregateResult ar : [
            SELECT Industry i FROM Account WHERE Industry != NULL GROUP BY Industry
        ]) {
            used.add((String)ar.get('i'));
        }
        for (Schema.PicklistEntry pe : Account.Industry.getDescribe().getPicklistValues()) {
            if (pe.isActive() && !used.contains(pe.getValue())) {
                return pe.getValue();
            }
        }
        // fallback: first active value
        for (Schema.PicklistEntry pe : Account.Industry.getDescribe().getPicklistValues()) {
            if (pe.isActive()) return pe.getValue();
        }
        return null;
    }

    // Pick another unused Industry, excluding a set.
    private static String pickAnotherUnusedIndustry(Set<String> exclude) {
        Set<String> used = new Set<String>();
        for (AggregateResult ar : [
            SELECT Industry i FROM Account WHERE Industry != NULL GROUP BY Industry
        ]) {
            used.add((String)ar.get('i'));
        }
        used.addAll(exclude);
        for (Schema.PicklistEntry pe : Account.Industry.getDescribe().getPicklistValues()) {
            if (pe.isActive() && !used.contains(pe.getValue())) {
                return pe.getValue();
            }
        }
        // fallback: first active not in exclude
        for (Schema.PicklistEntry pe : Account.Industry.getDescribe().getPicklistValues()) {
            if (pe.isActive() && !exclude.contains(pe.getValue())) return pe.getValue();
        }
        return null;
    }

    // Minimal account factory.
    private static Account mk(String name, String industry, String phone, String accNum) {
        Account a = new Account(Name = name, AccountNumber = accNum);
        if (industry != null) a.Industry = industry;
        if (phone    != null) a.Phone    = phone;
        return a;
    }

    // Seed one Account for the given AccountNumber so handler’s SOQL never throws.
    private static Account seedByAccountNumber(String accNum) {
        String ind = pickUnusedIndustry();
        Account seed = new Account(Name='Seed-'+accNum, AccountNumber=accNum, Industry=ind, Phone='0800000000');
        insert seed;
        return seed;
    }

    // Check if "Prospect" type exists.
    private static Boolean hasProspectType() {
        for (Schema.PicklistEntry p : Account.Type.getDescribe().getPicklistValues()) {
            if (p.isActive() && p.getValue() == 'Prospect') return true;
        }
        return false;
    }

    /* ---------- tests ---------- */

    @IsTest
    static void test_BeforeInsert_Blocks_MissingIndustry() {
        String accNum = 'ACC-MISS-IND';
        seedByAccountNumber(accNum); // avoid SOQL no-rows

        Account a = mk('NoInd', null, '0811111111', accNum);

        try {
            insert a;
            System.assert(false, 'Should fail for blank Industry');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Industry cannot be empty.'));
        }
    }

    @IsTest
    static void test_BeforeInsert_Blocks_MissingPhone() {
        String accNum = 'ACC-MISS-PHONE';
        seedByAccountNumber(accNum);

        String ind = pickUnusedIndustry();
        Account a = mk('NoPhone', ind, null, accNum);

        try {
            insert a;
            System.assert(false, 'Should fail for blank Phone');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Phone number cannot be empty.'));
        }
    }

    @IsTest
    static void test_BeforeInsert_Blocks_DuplicateIndustry() {
        // Choose an unused Industry so the first insert passes.
        String dupInd = pickUnusedIndustry();

        // Seed different account numbers so the parent-link query is safe.
        seedByAccountNumber('ACC-DUP-A1');
        seedByAccountNumber('ACC-DUP-A2');

        Account a1 = mk('A1', dupInd, '0812222222', 'ACC-DUP-A1');
        insert a1; // first with dupInd succeeds

        Account a2 = mk('A2', dupInd, '0813333333', 'ACC-DUP-A2');
        try {
            insert a2;
            System.assert(false, 'Should fail for duplicate Industry');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('An account with this Industry already exists.'));
        }
    }

    @IsTest
    static void test_BeforeInsert_SetsParent_ByAccountNumber() {
        String accNum = 'ACC-PARENT-001';
        Account parent = seedByAccountNumber(accNum); // existing row with same number

        // Use a different, unused Industry to stay clean.
        String childInd = pickAnotherUnusedIndustry(new Set<String>{ parent.Industry });

        Account child = mk('Child', childInd, '0815555555', accNum);

        Test.startTest();
        insert child;
        Test.stopTest();

        child = [SELECT ParentId FROM Account WHERE Id = :child.Id];
        System.assertEquals(parent.Id, child.ParentId, 'ParentId should be set from existing AccountNumber');
    }

    @IsTest
    static void test_BeforeUpdate_Valid_And_ValidationBlocks() {
        // Create two valid accounts with different unused industries.
        String i1 = pickUnusedIndustry();
        String i2 = pickAnotherUnusedIndustry(new Set<String>{ i1 });

        seedByAccountNumber('ACC-UPD-A1');
        seedByAccountNumber('ACC-UPD-A2');

        Account a1 = mk('Upd-A1', i1, '0816666666', 'ACC-UPD-A1'); insert a1;
        Account a2 = mk('Upd-A2', i2, '0817777777', 'ACC-UPD-A2'); insert a2;

        // Valid update (change industry to another unused)
        String i3 = pickAnotherUnusedIndustry(new Set<String>{ i1, i2 });
        a1.Industry = i3; a1.Phone = '0816666699';
        update a1;
        System.assertEquals(i3, [SELECT Industry FROM Account WHERE Id = :a1.Id].Industry);

        // Duplicate industry on update (a2 -> i3 which a1 now holds)
        a2.Industry = i3;
        try {
            update a2;
            System.assert(false, 'Should fail duplicate Industry on update');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('An account with this Industry already exists.'));
        }

        // Blank phone on update
        a1 = [SELECT Id, Phone FROM Account WHERE Id = :a1.Id];
        a1.Phone = null;
        try {
            update a1;
            System.assert(false, 'Should fail blank phone on update');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Phone number cannot be empty.'));
        }
    }

    @IsTest
    static void test_AfterInsert_CreatesOpportunity_ForProspect() {
        String accNum = 'ACC-PROSPECT';
        seedByAccountNumber(accNum);

        String ind = pickUnusedIndustry();
        Account a = mk('Prospect Acc', ind, '0818888888', accNum);
        if (hasProspectType()) a.Type = 'Prospect';

        insert a;

        Integer cnt = [SELECT COUNT() FROM Opportunity WHERE AccountId = :a.Id];
        if (hasProspectType()) {
            System.assertEquals(1, cnt, 'Should create an Opportunity for Prospect');
        } else {
            // If org has no "Prospect" picklist value, nothing should be created.
            System.assertEquals(0, cnt);
        }
    }
}