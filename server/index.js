const express=require('express'),Database=require('better-sqlite3'),bcrypt=require('bcryptjs'),jwt=require('jsonwebtoken'),fs=require('fs'),path=require('path');
const SECRET=process.env.JWT_SECRET||'dev-secret-change-me', PORT=process.env.PORT||3000;
const db=new Database(process.env.DB_FILE||path.join(__dirname,'../database/maak.db'));
db.pragma('foreign_keys=ON');
const notify=(uid,body)=>db.prepare('insert into notifications(user_id,body) values(?,?)').run(uid,body);
const uname=id=>db.prepare('select name from users where id=?').get(id).name;
if(!db.prepare("select name from sqlite_master where name='users'").get()){
  for(const f of['schema.sql','seed.sql'])db.exec(fs.readFileSync(path.join(__dirname,'../database',f),'utf8'));
  db.prepare('update users set password_hash=?').run(bcrypt.hashSync('demo123',8)); // comptes démo : mot de passe demo123
}
db.exec("CREATE TABLE IF NOT EXISTS notifications(id INTEGER PRIMARY KEY AUTOINCREMENT,user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,body TEXT NOT NULL,read_at DATETIME,created_at DATETIME DEFAULT CURRENT_TIMESTAMP)");
db.exec(fs.readFileSync(path.join(__dirname,'../database/migrations/ghofrane_sayari.sql'),'utf8'));
const app=express();app.use(express.json());
const auth=(req,res,next)=>{try{req.u=jwt.verify((req.headers.authorization||'').slice(7),SECRET);next()}catch{res.status(401).json({error:'Non authentifié'})}};
const sign=u=>({token:jwt.sign({id:u.id,role:u.role},SECRET,{expiresIn:'7d'}),user:{id:u.id,name:u.name,role:u.role,city:u.city}});
const bad=(res,m,c=400)=>res.status(c).json({error:m});

if(process.env.NODE_ENV=='production'&&!process.env.JWT_SECRET)throw new Error('JWT_SECRET requis en production');
app.use((q,r,n)=>{r.set({'Access-Control-Allow-Origin':process.env.CORS_ORIGIN||'*','Access-Control-Allow-Headers':'Content-Type, Authorization','Access-Control-Allow-Methods':'GET,POST,PUT,PATCH,OPTIONS','X-Content-Type-Options':'nosniff','X-Frame-Options':'DENY','Referrer-Policy':'no-referrer'});q.method=='OPTIONS'?r.sendStatus(204):n()});
const hits=new Map();
app.use('/api/auth',(q,r,n)=>{const t=Date.now(),a=(hits.get(q.ip)||[]).filter(x=>t-x<60000);a.push(t);hits.set(q.ip,a);a.length>20?bad(r,'Trop de tentatives, réessayez dans une minute',429):n()});
app.post('/api/auth/register',(req,res)=>{
  const{name,email,password,role,city,level}=req.body||{};
  const cleanName=typeof name=='string'?name.trim():'',cleanEmail=typeof email=='string'?email.trim().toLowerCase():'';
  if(cleanName.length<2||cleanName.length>100||!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(cleanEmail)||typeof password!='string'||password.length<6||Buffer.byteLength(password,'utf8')>72||!['student','tutor'].includes(role))return bad(res,'Champs invalides (nom, e-mail ou mot de passe)');
  if((city!=null&&(typeof city!='string'||city.length>100))||(level!=null&&(typeof level!='string'||level.length>100)))return bad(res,'Ville ou niveau invalide');
  if(db.prepare('select 1 from users where email=?').get(cleanEmail))return bad(res,'E-mail déjà utilisé',409);
  const id=db.prepare('insert into users(name,email,password_hash,role,city,level) values(?,?,?,?,?,?)').run(cleanName,cleanEmail,bcrypt.hashSync(password,10),role,city||null,level||null).lastInsertRowid;
  if(role=='tutor')db.prepare('insert into tutor_profiles(user_id) values(?)').run(id);
  res.status(201).json(sign(db.prepare('select * from users where id=?').get(id)));
});
app.post('/api/auth/login',(req,res)=>{
  const{email,password}=req.body||{},cleanEmail=typeof email=='string'?email.trim().toLowerCase():'',u=db.prepare('select * from users where email=?').get(cleanEmail);
  if(typeof password!='string'||!u||!bcrypt.compareSync(password,u.password_hash))return bad(res,'Identifiants incorrects',401);
  res.json(sign(u));
});
const tutors=()=>db.prepare('select u.id,u.name n,tp.university u,u.city c,tp.hourly_rate p,tp.bio b,tp.levels,tp.modes,tp.rating_avg r,tp.rating_count rv from users u join tutor_profiles tp on tp.user_id=u.id where tp.is_available=1').all()
 .map(t=>({...t,l:t.levels.split(','),md:t.modes.split(','),
  m:db.prepare('select s.name from tutor_subjects ts join subjects s on s.id=ts.subject_id where ts.tutor_id=?').all(t.id).map(x=>x.name),
  s:db.prepare('select slot from availabilities where tutor_id=?').all(t.id).map(x=>x.slot)}));
app.get('/api/tutors',(req,res)=>{const{subject,level,city,q}=req.query;
  res.json(tutors().filter(t=>(!subject||t.m.includes(subject))&&(!level||t.l.includes(level))&&(!city||t.c==city)&&(!q||(t.n+t.u+t.m.join()).toLowerCase().includes(q.toLowerCase()))))});
app.put('/api/tutor/profile',auth,(req,res)=>{
  if(req.u.role!='tutor')return bad(res,'Réservé aux tuteurs',403);
  const{hourly_rate,bio,is_available,subjects,slots}=req.body||{};
  if(hourly_rate!=null&&(!Number.isSafeInteger(hourly_rate)||hourly_rate<1))return bad(res,'Tarif invalide');
  if(bio!=null&&(typeof bio!='string'||bio.length>2000))return bad(res,'Présentation invalide');
  if(is_available!=null&&typeof is_available!='boolean'&&is_available!==0&&is_available!==1)return bad(res,'Disponibilité invalide');
  if(subjects!=null&&(!Array.isArray(subjects)||subjects.length>20||subjects.some(s=>typeof s!='string')||new Set(subjects).size!==subjects.length))return bad(res,'Liste de matières invalide');
  if(slots!=null&&(!Array.isArray(slots)||slots.length>40||slots.some(s=>typeof s!='string'||!s.trim()||s.length>20)||new Set(slots).size!==slots.length))return bad(res,'Liste de créneaux invalide');
  if(Array.isArray(subjects)&&subjects.some(n=>!db.prepare('select 1 from subjects where name=?').get(n)))return bad(res,'Matière inconnue');
  db.transaction(()=>{
    db.prepare('update tutor_profiles set hourly_rate=coalesce(?,hourly_rate),bio=coalesce(?,bio),is_available=coalesce(?,is_available) where user_id=?').run(hourly_rate??null,bio??null,is_available==null?null:+is_available,req.u.id);
    if(Array.isArray(subjects)){db.prepare('delete from tutor_subjects where tutor_id=?').run(req.u.id);
      for(const n of subjects){const s=db.prepare('select id from subjects where name=?').get(n);db.prepare('insert into tutor_subjects values(?,?)').run(req.u.id,s.id)}}
    if(Array.isArray(slots)){db.prepare('delete from availabilities where tutor_id=?').run(req.u.id);for(const s of slots)db.prepare('insert into availabilities(tutor_id,slot) values(?,?)').run(req.u.id,s)}
  })();
  res.json({ok:true});
});
app.post('/api/bookings',auth,(req,res)=>{
  const{tutor_id,slot,mode,subject}=req.body||{};
  if(req.u.role!='student')return bad(res,'Réservé aux élèves',403);
  const tutorId=Number(tutor_id),profile=db.prepare("select tp.is_available,tp.modes from tutor_profiles tp join users u on u.id=tp.user_id where tp.user_id=? and u.role='tutor'").get(tutorId);
  if(!Number.isSafeInteger(tutorId)||!profile||typeof slot!='string'||!slot.trim()||slot.length>20||typeof mode!='string')return bad(res,'Réservation invalide');
  if(!profile.is_available||!profile.modes.split(',').includes(mode)||!db.prepare('select 1 from availabilities where tutor_id=? and slot=?').get(tutorId,slot))return bad(res,'Créneau ou mode indisponible');
  let subjectId=null;
  if(subject!=null){if(typeof subject!='string')return bad(res,'Matière invalide');const s=db.prepare('select s.id from subjects s join tutor_subjects ts on ts.subject_id=s.id where ts.tutor_id=? and s.name=?').get(tutorId,subject);if(!s)return bad(res,'Matière non enseignée par ce tuteur');subjectId=s.id}
  const id=db.prepare('insert into bookings(student_id,tutor_id,subject_id,slot,mode) values(?,?,?,?,?)').run(req.u.id,tutorId,subjectId,slot,mode).lastInsertRowid;
  notify(tutorId,'Nouvelle demande de '+uname(req.u.id)+' : '+slot+' ('+mode+')');
  res.status(201).json({id,status:'pending'});
});
app.get('/api/bookings',auth,(req,res)=>res.json(db.prepare('select b.id,b.tutor_id,b.student_id,b.slot,b.mode,b.status,su.name student_name,su.level student_level,s.name subject,(select 1 from reviews r where r.booking_id=b.id) rated from bookings b join users su on su.id=b.student_id left join subjects s on s.id=b.subject_id where b.student_id=? or b.tutor_id=? order by b.id desc').all(req.u.id,req.u.id)));
app.patch('/api/bookings/:id',auth,(req,res)=>{
  const b=db.prepare('select * from bookings where id=?').get(req.params.id),st=(req.body||{}).status;
  if(!b)return bad(res,'Introuvable',404);
  const tutor=b.tutor_id==req.u.id,student=b.student_id==req.u.id;
  if(!tutor&&!student)return bad(res,'Action non autorisée',403);
  const ok=(tutor&&b.status=='pending'&&['confirmed','declined'].includes(st))||(tutor&&b.status=='confirmed'&&st=='done')||(student&&['pending','confirmed'].includes(b.status)&&st=='cancelled');
  if(!ok)return bad(res,'Transition de réservation invalide',409);
  db.prepare('update bookings set status=? where id=?').run(st,b.id);
  const L={confirmed:'confirmée',declined:'refusée',cancelled:'annulée',done:'terminée'};notify(req.u.id==b.tutor_id?b.student_id:b.tutor_id,'Séance '+L[st]+' : '+b.slot+' ('+uname(req.u.id)+')');
  res.json({id:b.id,status:st});
});
app.get('/api/messages',auth,(req,res)=>res.json(db.prepare('select m.*,su.name sender_name,ru.name receiver_name from messages m join users su on su.id=m.sender_id join users ru on ru.id=m.receiver_id where m.sender_id=? or m.receiver_id=? order by m.id').all(req.u.id,req.u.id)));
app.post('/api/messages',auth,(req,res)=>{const{to,body}=req.body||{};
  const receiverId=Number(to);
  if(!Number.isSafeInteger(receiverId)||!db.prepare('select 1 from users where id=?').get(receiverId)||typeof body!='string'||!body.trim()||body.length>1000)return bad(res,'Message invalide');
  const id=db.prepare('insert into messages(sender_id,receiver_id,body) values(?,?,?)').run(req.u.id,receiverId,body.trim()).lastInsertRowid;
  notify(to,'Nouveau message de '+uname(req.u.id));res.status(201).json({id})});
app.post('/api/reviews',auth,(req,res)=>{
  const{booking_id,rating,comment}=req.body||{},bookingId=Number(booking_id),b=Number.isSafeInteger(bookingId)?db.prepare('select * from bookings where id=? and student_id=?').get(bookingId,req.u.id):null;
  if(!b||b.status!='done'||!Number.isInteger(rating)||rating<1||rating>5||comment!=null&&(typeof comment!='string'||comment.length>2000))return bad(res,'Avis impossible : données invalides ou séance non terminée');
  if(db.prepare('select 1 from reviews where booking_id=?').get(b.id))return bad(res,'Cette séance a déjà été évaluée',409);
  db.prepare('insert into reviews(booking_id,rating,comment) values(?,?,?)').run(b.id,rating,comment||null);
  db.prepare('update tutor_profiles set rating_avg=(select avg(r.rating) from reviews r join bookings k on k.id=r.booking_id where k.tutor_id=?),rating_count=(select count(*) from reviews r join bookings k on k.id=r.booking_id where k.tutor_id=?) where user_id=?').run(b.tutor_id,b.tutor_id,b.tutor_id);
  res.status(201).json({ok:true});
});
app.get('/api/notifications',auth,(req,res)=>res.json(db.prepare('select id,body,read_at,created_at from notifications where user_id=? order by id desc limit 50').all(req.u.id)));
app.post('/api/notifications/read',auth,(req,res)=>{db.prepare('update notifications set read_at=CURRENT_TIMESTAMP where user_id=? and read_at is null').run(req.u.id);res.json({ok:true})});
app.get('/api/me',auth,(req,res)=>{
  const u=db.prepare('select id,name,email,role,city,level from users where id=?').get(req.u.id);
  if(u.role=='tutor'){const p=db.prepare('select hourly_rate p,bio b,is_available "on" from tutor_profiles where user_id=?').get(u.id);
    p.mat=db.prepare('select s.name from tutor_subjects ts join subjects s on s.id=ts.subject_id where ts.tutor_id=?').all(u.id).map(x=>x.name);p.slots=db.prepare('select slot from availabilities where tutor_id=?').all(u.id).map(x=>x.slot);u.profile=p}
  res.json(u)});
app.get('/api/tutors/:id/reviews',(req,res)=>res.json(db.prepare('select r.rating,r.comment,su.name student,r.created_at from reviews r join bookings b on b.id=r.booking_id join users su on su.id=b.student_id where b.tutor_id=? order by r.id desc limit 20').all(req.params.id)));
app.use(express.static(path.join(__dirname,'../public')));
app.use((e,req,res,next)=>{console.error(e);res.status(500).json({error:'Erreur serveur'})});
app.listen(PORT,()=>console.log('MAAK sur http://localhost:'+PORT));
