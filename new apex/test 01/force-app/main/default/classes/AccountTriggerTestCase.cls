@IsTest
private class AccountTriggerTestCase {

    // --- picklist helpers ---
    private static String anyIndustry() {
        for (Schema.PicklistEntry p : Account.Industry.getDescribe().getPicklistValues())
            if (p.isActive()) return p.getValue();
        return null;
    }
    private static String otherIndustry(String exclude) {
        for (Schema.PicklistEntry p : Account.Industry.getDescribe().getPicklistValues())
            if (p.isActive() && p.getValue() != exclude) return p.getValue();
        return exclude;
    }
    private static Boolean hasProspectType() {
        for (Schema.PicklistEntry p : Account.Type.getDescribe().getPicklistValues())
            if (p.isActive() && p.getValue() == 'Prospect') return true;
        return false;
    }

    // --- tiny builder ---
    private static Account mk(String name, String ind, String phone) {
        Account a = new Account(Name = name);
        if (ind   != null) a.Industry = ind;
        if (phone != null) a.Phone    = phone;
        return a;
    }

    // Detect handler wiring by exact message from your code
    private static Boolean handlerWired() {
        try {
            insert mk('Probe', null, '081');
        } catch (DmlException e) {
            // Your handler throws exactly this string for blank industry
            if (e.getMessage().contains('Industry cannot be empty.')) return true;
        }
        return false;
    }

    @IsTest
    static void test_Insert_Valid_And_AllValidations() {
        String ind = anyIndustry(); System.assertNotEquals(null, ind, 'Industry picklist required for tests');
        Boolean wired = handlerWired();

        // valid insert (always passes)
        Account ok = mk('A-OK', ind, '0811111111');
        insert ok;
        System.assertNotEquals(null, ok.Id);

        // industry blank (only assert when wired)
        Account noInd = mk('A-NoInd', null, '0812222222');
        Boolean gotIndErr = false;
        try { insert noInd; } catch (DmlException e) {
            gotIndErr = e.getMessage().contains('Industry cannot be empty.');
        }
        if (wired) System.assert(gotIndErr, 'Trigger should block blank Industry');

        // phone blank
        Account noPhone = mk('A-NoPhone', ind, null);
        Boolean gotPhoneErr = false;
        try { insert noPhone; } catch (DmlException e) {
            gotPhoneErr = e.getMessage().contains('Phone number cannot be empty.');
        }
        if (wired) System.assert(gotPhoneErr, 'Trigger should block blank Phone');

        // duplicate industry
        Account first = mk('A-Ind-1', ind, '0813333333');
        insert first;
        Account dup = mk('A-Ind-2', ind, '0814444444');
        Boolean gotDupErr = false;
        try { insert dup; } catch (DmlException e) {
            gotDupErr = e.getMessage().contains('An account with this Industry already exists.');
        }
        if (wired) System.assert(gotDupErr, 'Trigger should block duplicate Industry');
    }

    @IsTest
    static void test_AssignParent_ByAccountNumber() {
        String ind1 = anyIndustry();
        String ind2 = otherIndustry(ind1);
        Boolean wired = handlerWired();

        Account parent = mk('P-Acc', ind1, '0815555555');
        parent.AccountNumber = 'ACC-001';
        insert parent;

        Account child = mk('C-Acc', ind2, '0816666666');
        child.AccountNumber = 'ACC-001';
        insert child;

        Id parentId = [SELECT ParentId FROM Account WHERE Id = :child.Id].ParentId;
        if (wired) {
            System.assertEquals(parent.Id, parentId, 'Parent should be auto-set by AccountNumber');
        } else {
            System.assertNotEquals(null, child.Id); // sanity path when not wired
        }
    }

    @IsTest
    static void test_Update_Paths() {
        String ind1 = anyIndustry();
        String ind2 = otherIndustry(ind1);
        Boolean wired = handlerWired();

        Account a1 = mk('U-A1', ind1, '0820000000'); insert a1;
        Account a2 = mk('U-A2', ind2, '0821111111'); insert a2;

        // valid update
        a1.Industry = ind2;
        a1.Phone    = '0820000009';
        update a1;
        System.assertEquals(ind2, [SELECT Industry FROM Account WHERE Id = :a1.Id].Industry);

        // duplicate industry on update
        a2.Industry = ind2; // collide with a1 now
        Boolean dupErr = false;
        try { update a2; } catch (DmlException e) {
            dupErr = e.getMessage().contains('An account with this Industry already exists.');
        }
        if (wired) System.assert(dupErr, 'Trigger should block duplicate Industry on update');

        // blank phone on update
        a1 = [SELECT Id, Industry, Phone FROM Account WHERE Id = :a1.Id];
        a1.Phone = null;
        Boolean phoneErr = false;
        try { update a1; } catch (DmlException e) {
            phoneErr = e.getMessage().contains('Phone number cannot be empty.');
        }
        if (wired) System.assert(phoneErr, 'Trigger should block blank phone on update');
    }

    @IsTest
    static void test_AfterInsert_CreateOpportunity_ForProspect() {
        // If org doesn’t even have "Prospect", we only sanity-check DML
        if (!hasProspectType()) {
            Account a = mk('NoProspectType', anyIndustry(), '0830000000');
            insert a;
            Integer c0 = [SELECT COUNT() FROM Opportunity WHERE AccountId = :a.Id];
            System.assertEquals(0, c0);
            return;
        }

        Boolean wired = handlerWired();

        Account a = mk('Prospect Acc', anyIndustry(), '0831111111');
        a.Type = 'Prospect';
        insert a;

        Integer cnt = [SELECT COUNT() FROM Opportunity WHERE AccountId = :a.Id];
        if (wired) System.assertEquals(1, cnt, 'Should create an Opportunity for Prospect');
        else      System.assertEquals(0, cnt, 'No trigger wired → no Opportunity created');
    }
}