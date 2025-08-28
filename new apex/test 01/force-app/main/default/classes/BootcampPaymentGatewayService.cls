/*
with -> melihat access dari data, base on ?? Datanya akan terquery di database sesuai dengan sharing rules yang ada
without -> bisa bypass, jika ada query didalamnya, dia bisa melihat seluruh query di dalamnya 
*/

/* 
Penjelasan Kode:
Kelas ini adalah layanan untuk mengakses gateway pembayaran. Kelas ini menggunakan metode HTTP untuk mengirim permintaan ke endpoint tertentu dan mengembalikan respons dari server. Dalam metode getPayments(), sebuah objek HttpRequest dibuat untuk mengonfigurasi permintaan, termasuk pengaturan endpoint, metode, dan waktu tunggu. Setelah permintaan dikirim, responsnya dicetak ke log untuk tujuan debugging.
*/
public without sharing class BootcampPaymentGatewayService {
    public static HttpResponse getPayments() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://hu-edition-needs-edt.trycloudflare.com/payments');
        req.setMethod('GET');
        req.setTimeout(120000);

        HttpResponse res = new HttpResponse();
        Http ht = new Http();

        res = ht.send(req);

        System.debug('res: ' + res);
        System.debug('body: ' + res.getBody());
        return res;
    }

    public static HttpResponse getPaymentById(String payment_id) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://hu-edition-needs-edt.trycloudflare.com/payments/' + payment_id);
        req.setMethod('GET');
        req.setTimeout(120000);

        HttpResponse res = new HttpResponse();
        Http ht = new Http();

        res = ht.send(req);

        System.debug('res: ' + res);
        System.debug('body: ' + res.getBody());
        return res;
    }

    public static HttpResponse getPaymentFilteredbyStatus(String status) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://hu-edition-needs-edt.trycloudflare.com/payments?status=' + status);
        req.setMethod('GET');
        req.setTimeout(120000);

        HttpResponse res = new HttpResponse();
        Http ht = new Http();

        res = ht.send(req);

        System.debug('res: ' + res);
        System.debug('body: ' + res.getBody());
        return res;
    }

    public static HttpResponse getPaymentFilteredbyMethod(String method) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://hu-edition-needs-edt.trycloudflare.com/payments?payment_method=' + method);
        req.setMethod('GET');
        req.setTimeout(120000);

        HttpResponse res = new HttpResponse();
        Http ht = new Http();

        res = ht.send(req);

        System.debug('res: ' + res);
        System.debug('body: ' + res.getBody());
        return res;
    }

    public static HttpResponse createNewPayment(String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://hu-edition-needs-edt.trycloudflare.com/payments');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setBody(body);

        Http ht = new Http();
        HttpResponse res = ht.send(req);

        System.debug('res: ' + res);
        System.debug('body: ' + res.getBody());
        return res;
    }

    public static HttpResponse updatePayment(String extId, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://hu-edition-needs-edt.trycloudflare.com/payments/' + extId);
        req.setMethod('PUT');
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setBody(body);

        Http ht = new Http();
        HttpResponse res = ht.send(req);

        System.debug('res: ' + res);
        System.debug('body: ' + res.getBody());
        return res;
    }

    public static HttpResponse deletePayment(String payment_id) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://hu-edition-needs-edt.trycloudflare.com/payments/' + payment_id);
        req.setMethod('DELETE');
        req.setTimeout(120000);

        Http ht = new Http();
        HttpResponse res = ht.send(req);

        System.debug('res: ' + res);
        System.debug('body: ' + res.getBody());
        return res;
    }
}

/*
    Service ini berisi data yang akan dikirim ke API.
    Hasil Service bentuknya udah response, yang akan diolah di controller.
*/