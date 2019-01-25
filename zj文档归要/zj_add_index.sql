-- 2018-7-16 添加函数
delimiter;;
CREATE DEFINER=`test`@`%` FUNCTION `getSumRanking`(pExamId varchar(36), pSumScore int, pPeriodId varchar(36), pGradeId varchar(36), pClassId varchar(36)) RETURNS int(11)
begin 
	declare gradeNo int;
		select count(1)+1 into gradeNo from (
				SELECT sum(sss.score) sumScore 
				FROM ex_exam_define ed 
				left join ex_student_subject_exam sse on sse.examID = ed.examID 
				left join  ex_student_subject_score sss on sss.subjectExamID = sse.subjectExamID 
				where ed.examID = pExamId  and sse.status = '1' and sse.periodID = pPeriodId and sse.gradeID = pGradeId 
				and if(isnull(pClassId), 1=1, sse.classId = pClassId)
				and ed.validFlag = 'Y' and sse.validFlag = 'Y' and sss.validFlag = 'Y' group by sss.studentID
			) classScore where if(isnull(classScore.sumScore),0,classScore.sumScore) > if(isnull(pSumScore ),0,pSumScore );
	return gradeNo;
end;;
delimiter;

delimiter;;
CREATE DEFINER=`test`@`%` FUNCTION `getSumAvg`(pExamId varchar(36), pPeriodId varchar(36), pGradeId varchar(36), pClassId varchar(36)) RETURNS double
begin 
	declare avgScore double;
		select round(avg(if(isnull(sumScore), 0, sumScore)), 2) into avgScore from (
				SELECT sum(sss.score) sumScore 
				FROM ex_exam_define ed 
				left join ex_student_subject_exam sse on sse.examID = ed.examID 
				left join  ex_student_subject_score sss on sss.subjectExamID = sse.subjectExamID 
				where ed.examID = pExamId and sse.status = '1' and sse.periodID = pPeriodId and sse.gradeID = pGradeId
				and if(isnull(pClassId), 1=1, sse.classId = pClassId)
				and ed.validFlag = 'Y' and sse.validFlag = 'Y' and sss.validFlag = 'Y' group by sss.studentID) grade;
	return avgScore;
end;;
delimiter;


delimiter;;
CREATE DEFINER=`test`@`%` FUNCTION `getSumMax`(pExamId varchar(36), pPeriodId varchar(36), pGradeId varchar(36), pClassId varchar(36)) RETURNS double
begin 
	declare maxScore double;
		select max(sumScore) into maxScore from (
				SELECT sum(sss.score) sumScore 
				FROM ex_exam_define ed 
				left join ex_student_subject_exam sse on sse.examID = ed.examID 
				left join  ex_student_subject_score sss on sss.subjectExamID = sse.subjectExamID 
				where ed.examID = pExamId and sse.status = '1' and sse.periodID = pPeriodId and sse.gradeID = pGradeId  
				and if(isnull(pClassId), 1=1, sse.classId = pClassId)
				and ed.validFlag = 'Y' and sse.validFlag = 'Y' and sss.validFlag = 'Y' group by sss.studentID
			) grade ;
	return maxScore;
end;;
delimiter;

DROP FUNCTION IF EXISTS `getGradeSumAvg`;
delimiter;;
CREATE DEFINER=`test`@`%` FUNCTION `getGradeSumAvg`(pExamId varchar(36), pPeriodId varchar(36), pGradeId varchar(36)) RETURNS double
begin 
	declare avgScore double;
		select round(avg(if(isnull(sumScore), 0, sumScore)), 2) into avgScore from (
				SELECT sum(sss.score) sumScore 
				FROM ex_exam_define ed 
				left join ex_student_subject_exam sse on sse.examID = ed.examID 
				left join  ex_student_subject_score sss on sss.subjectExamID = sse.subjectExamID 
				where ed.examID = pExamId and sse.status = '1' and sse.periodID = pPeriodId and sse.gradeID = pGradeId
				and ed.validFlag = 'Y' and sse.validFlag = 'Y' and sss.validFlag = 'Y' group by sss.studentID) grade;
	return avgScore;
end;;
delimiter;

-- 2018-7-26
alter table bd_school modify openMan varchar(36) DEFAULT NULL;


-- 2018-7-27
create table um_partner_user(
	id int not null auto_increment,
	uid int not null comment '合作方uid',
	user_id varchar(36) not null comment '对应数字校园用户',
	school_id int not null comment '学校id',
	remark varchar(36) default null comment '备注',
	`valid_flag` varchar(2) default null,
	`make_time` datetime default null,
	`make_user` varchar(36) default null,
	`modify_time` datetime DEFAULT NULL,
  `modify_user` varchar(36) DEFAULT NULL,
	primary key (id)
)engine=innodb default charset=utf8 comment='合作方用户';

INSERT INTO `ecampus_new`.`sys_code` (`codeId`, `schoolId`, `codeType`, `codeValue`, `codeName`, `codeRemark`)
 VALUES (unix_timestamp(), '', 'Subject', '99', '其他', '课程');


-- 2018-8-1-

CREATE TABLE `um_partner_auth` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  school_id varchar(36) not null,
	`secret` varchar(100) NOT NULL COMMENT '伙伴secret',
  `valid_flag` char(1) DEFAULT NULL COMMENT '是否有效',
  `expires_in` int(11) DEFAULT NULL,
  `make_time` datetime NOT NULL COMMENT '创建时间',
  `modify_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 comment = '合作方认证';