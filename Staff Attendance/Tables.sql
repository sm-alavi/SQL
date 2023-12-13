
CREATE SCHEMA [att]

CREATE TABLE [att].[WeekDay](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idx] [int] NULL,
	[name] [nvarchar](10) NULL,
	[caption] [nvarchar](10) NULL,
	[abbv] [nvarchar](10) NULL,
 CONSTRAINT [PK_WeekDay] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


CREATE TABLE [att].[ManualAttendanceEntry](
	[id] [bigint] IDENTITY(-9223372036854775800,1) NOT NULL,
	[personid] [nvarchar](10) NULL,
	[kind] [nvarchar](10) NULL,
	[date1] [nvarchar](10) NULL,
	[time] [time](7) NULL,
	[description] [nvarchar](250) NULL,
	[send_to] [nvarchar](50) NULL,
	[status] [nvarchar](50) NULL,
	[addby] [nvarchar](250) NULL,
	[addby2] [nvarchar](250) NULL,
 CONSTRAINT [PK_manualattendanceentry] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [att].[Calendar](
	[Date] [date] NOT NULL,
	[DayName] [nvarchar](10) NULL,
	[PersianDate] [nvarchar](10) NULL,
 CONSTRAINT [PK_Calendar] PRIMARY KEY CLUSTERED 
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [att].[ShiftType](
	[id] [int] NOT NULL,
	[name] [nvarchar](10) NULL,
	[caption] [nvarchar](10) NULL,
 CONSTRAINT [PK_shifttype] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [att].[Shift](
	[id] [bigint] IDENTITY(-9223372036854775800,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[shifttypeid] [int] NULL,
	[shiftcode] [nvarchar](15) NULL,
	[description] [nvarchar](200) NULL,
	[startdate] [nvarchar](10) NULL,
	[cycledays] [int] NULL,
	[overtime_ceiling] [int] NULL,
	[addby] [nvarchar](250) NULL,
 CONSTRAINT [PK_shift] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


CREATE TABLE [att].[EmployeeGroup](
	[id] [bigint] IDENTITY(-9223372036854775800,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[description] [nvarchar](200) NULL,
	[addby] [nvarchar](250) NULL,
 CONSTRAINT [PK_employeegroup] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


CREATE TABLE [att].[EmployeeGroupPerson](
	[id] [bigint] IDENTITY(-9223372036854775800,1) NOT NULL,
	[groupid] [bigint] NULL,
	[personid] [nvarchar](10) NULL,
	[date1] [nvarchar](10) NULL,
	[addby] [nvarchar](250) NULL,
 CONSTRAINT [PK_employeegroupperson] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


CREATE TABLE [att].[GroupShiftAssignment](
	[id] [bigint] IDENTITY(-9223372036854775800,1) NOT NULL,
	[groupid] [bigint] NULL,
	[shiftid] [bigint] NULL,
	[startdate] [nvarchar](10) NULL,
	[addby] [nvarchar](250) NULL,
 CONSTRAINT [PK_groupshiftassignment] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [att].[ShiftDetail](
	[id] [bigint] IDENTITY(-9223372036854775800,1) NOT NULL,
	[shiftid] [bigint] NULL,
	[description] [nvarchar](200) NULL,
	[date1] [nvarchar](10) NULL,
	[weekdayid] [int] NULL,
	[scheduleorder] [int] NULL,
	[starttime] [time](7) NULL,
	[startearlymin] [int] NULL,
	[startlatemin] [int] NULL,
	[endtime] [time](7) NULL,
	[endearlymin] [int] NULL,
	[endlatemin] [int] NULL,
	[isoffday] [bit] NULL,
	[is_continued_nextday] [bit] NULL,
	[overtime_ceiling] [int] NULL,
	[float_duty_min] [int] NULL,
	[addby] [nvarchar](250) NULL,
 CONSTRAINT [PK_shiftdetail] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [att].[Holiday](
	[id] [bigint] IDENTITY(-9223372036854775800,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[description] [nvarchar](200) NULL,
	[holidaydate] [nvarchar](10) NULL,
	[year] [int] NULL,
	[addby] [nvarchar](250) NULL,
 CONSTRAINT [PK_holiday] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [att].[AttendanceEntry](
	[id] [bigint] IDENTITY(-9223372036854775800,1) NOT NULL,
	[personid] [nvarchar](10) NULL,
	[datetime] [datetime] NULL,
	[addby] [nvarchar](250) NULL,
	[updated] [datetime] NULL,
 CONSTRAINT [PK_attendanceentry] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]






