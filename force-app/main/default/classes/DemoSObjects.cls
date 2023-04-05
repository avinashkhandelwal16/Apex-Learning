public class DemoSObjects {
    public void demoMethod(){
        Account acc = new Account(Name = 'test',Phone ='123456');
		//acc.Name = 'test';
		//acc.Phone = '123456';
		System.debug('acc =>'+acc);
    }
}