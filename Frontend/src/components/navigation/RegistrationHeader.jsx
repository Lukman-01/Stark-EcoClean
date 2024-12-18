import { useEffect, useState } from "react";
import { MdClose } from "react-icons/md";
import { Link, useLocation } from "react-router-dom";
import { useAccount } from "wagmi";
import dropdown from '../../assets/dropdown.svg';
import menuIcon from '../../assets/menuGreen.svg';
import { HeaderData } from '../../data/HeaderData';
import ConnectWalletButton from "../connections/connect_button";
import Logo from '../logo';
import { ADMIN_ADDRESS } from "../../utils";
import { useRecycleContract } from "../../context/RecycleContractProvider";

const Header = () => {
  const account = useAccount()
  const connectedAccount = account?.address
  const adminAddress = ADMIN_ADDRESS;
  const {account_category } = useRecycleContract()




    const {pathname} = useLocation();

  
    const [toggle_menu, setToggleMenu] = useState(false);
    const [showRegisterDropdown, setShowRegisterDropdown] = useState(false);
    const [showHomeDropDown, setShowHomeDropDown] = useState(false);
    const [showDashboardDropDown, setDashboardDropDown] = useState(false);

    // toggle menu
    const toggleMenu =() => {
        setToggleMenu(!toggle_menu)
    }

    // show register drop down when user hover over the "Register" link
    const registerDropdown = () => {
      setShowRegisterDropdown(!showRegisterDropdown);
    }

    // show home drop down when user hover over the "Home" link
    const homeDropdown = () => {
      setShowHomeDropDown(!showHomeDropDown);
    }

    // show home drop down when user hover over the "Home" link
    const dashboardDropdown = () => {
        setDashboardDropDown(!showDashboardDropDown);
      }

    // connect wallet
    const ConnectWallet = async () => {
        // initializeContract();
        // initializeRecycleContract();
    }    
    useEffect(() => {

      window.onresize = () => {
        if(window.innerWidth > 768){
          setToggleMenu(false)
        }
      }
      return () => {};

    }, [])

  return (
    <header className="container mx-auto w-full z-10 fixed bg-white top-0 font-montserrat font-bold text-base text-primary40 drop-shadow-md">
      <div className="w-[90%] mx-auto flex flex-row items-center h-20 justify-between md:justify-between">
        {/* logo */}
        <div className="w-12 h-12">
          <Link to={"/"}>
            <Logo />
          </Link>
        </div>

        <div className="w-full flex flex-row items-center justify-end md:justify-center">
          <div className="flex flex-row justify-between items-center w-full">
            {/* header links */}
            <ul
              className={`w-full absolute items-center md:static flex flex-col md:flex-row gap-2 lg:gap-[66px] px-4
                      ${!toggle_menu ? "-left-full -top-full" : " left-0 top-0 flex-col w-[80%] bg-white p-4 mt-20 rounded-b-md "}
                      transition-all duration-500
                      `}
            >
             <li 
                className={`w-fit hover:border-b hover:border-primary40 
                  hover:font-bold transition-all flex flex-row gap-2 my-4 
                  border-primary40 md:mr-4 ${pathname == "/" ? "border-b font-bold" : "font-normal"}`}
                  onMouseEnter={homeDropdown}
                  onMouseLeave={homeDropdown}
                >
                <Link to="/">Home</Link> <img src={dropdown} alt="dropdown icon" />
                {
                showHomeDropDown ?
                <div className=" inline-block">
                <div className="w-[13rem] absolute bg-white shadow-light border border-[#ddd] p-4">
                  <Link 
                    to={'/about-us'}
                    className={`w-fit hover:border-b hover:border-primary40 hover:font-bold transition-all flex flex-row gap-2 my-4 border-primary40 md:mr-4 ${pathname == "/about-us" ? "border-b font-bold" : "font-normal"}`}
                   >About Us
                  </Link>
                  <Link 
                    to={'/blog'}
                    className={`w-fit hover:border-b hover:border-primary40 hover:font-bold transition-all flex flex-row gap-2 my-4 border-primary40 md:mr-4 ${pathname == "/blog" ? "border-b font-bold" : "font-normal"}`}
                    >Blog
                    </Link>
                </div>
                </div>
                : ""
              }
              
              </li>

              { HeaderData.map((item, index) => (
                <li className={`w-fit mr-4 hover:border-b hover:border-primary40 my-4 hover:font-bold transition-all border-primary40 ${pathname == item.link ? "border-b font-bold" : "font-normal"}`} key={index}>
                  <Link to={item.link}>{item.title}</Link>
                </li>
              ))}
               
              {/* register link */}
              {!account_category ? 
                <li 
                  className={`relative w-fit hover:border-b font-normal
                  hover:cursor-pointer hover:border-primary40 hover:font-bold 
                  transition-all flex flex-row gap-2 my-4 border-primary40 
                  md:mr-4`}
                  onMouseEnter={registerDropdown}
                  onMouseLeave={registerDropdown}
                >Register<img src={dropdown} alt="dropdown icon" />
                {
                  showRegisterDropdown ?
                  <div className="inline-block">
                    <div className="w-[13rem] absolute bg-white shadow-light border border-[#ddd] p-4">
                      <Link 
                        to={"/register-user"}
                        className={`w-fit hover:border-b hover:border-primary40 hover:font-bold transition-all flex flex-row gap-2 my-4 border-primary40 md:mr-4 ${pathname === "/register-user" ? "border-b font-bold" : "font-normal"}`}
                      >User
                      </Link>
                      <Link 
                        to={"/register-company"}
                        className={`w-fit hover:border-b hover:border-primary40 hover:font-bold transition-all flex flex-row gap-2 my-4 border-primary40 md:mr-4 ${pathname === "/register-company" ? "border-b font-bold" : "font-normal"}`}
                        >Company
                        </Link>
                    </div>
                  </div>
                  : ""
                }
                  
                </li>
              : 
                connectedAccount && account_category === "picker" ? 
                    <li className={`w-fit mr-4 hover:border-b hover:border-primary40 my-4 hover:font-bold transition-all border-primary40 ${pathname == "/user-dashboard" ? "border-b font-bold" : "font-normal"}`}>
                        <Link to={`/user-dashboard`}>Dashboard</Link>
                    </li>
                :
                connectedAccount && account_category === "company" ?
                    <li className={`w-fit mr-4 hover:border-b hover:border-primary40 my-4 hover:font-bold transition-all border-primary40 ${pathname == "/company-dashboard" ? "border-b font-bold" : "font-normal"}`}>
                        <Link to={"/company-dashboard"}>Dashboard</Link>
                    </li>
                :
                connectedAccount && account_category === "admin" && connectedAccount.toLocaleLowerCase() === adminAddress?.toLocaleLowerCase() ?
                    <li className={`w-fit mr-4 hover:border-b hover:border-primary40 my-4 hover:font-bold transition-all border-primary40 ${pathname == "/admin-dashboard" ? "border-b font-bold" : "font-normal"}`}>
                        <Link to={"/admin-dashboard"}>Dashboard</Link>
                    </li>
                  : ""
              
            //   <li 
            //     className={`relative w-fit hover:border-b font-normal
            //     hover:cursor-pointer hover:border-primary40 hover:font-bold 
            //     transition-all flex flex-row gap-2 my-4 border-primary40 
            //     md:mr-4`}
            //     onMouseEnter={dashboardDropdown}
            //     onMouseLeave={dashboardDropdown}
            //     >Dashboard<img src={dropdown} alt="dropdown icon" />
            // {
            //   showDashboardDropDown ?
            //   <div className="inline-block">
            //     <div className="w-[13rem] absolute bg-white shadow-light border border-[#ddd] p-4">
            //       <Link 
            //         to={"/user-dashboard"}
            //         className={`w-fit hover:border-b hover:border-primary40 hover:font-bold transition-all flex flex-row gap-2 my-4 border-primary40 md:mr-4 ${pathname == "/user-dashboard" ? "border-b font-bold" : "font-normal"}`}
            //       >User
            //       </Link>
            //       <Link 
            //         to={"/company-dashboard"}
            //         className={`w-fit hover:border-b hover:border-primary40 hover:font-bold transition-all flex flex-row gap-2 my-4 border-primary40 md:mr-4 ${pathname == "/company-dashboard" ? "border-b font-bold" : "font-normal"}`}
            //         >Company
            //         </Link>
            //         <Link 
            //             to={"/admin-dashboard"}
            //             className={`w-fit hover:border-b hover:border-primary40 hover:font-bold transition-all flex flex-row gap-2 my-4 border-primary40 md:mr-4 ${pathname == "/admin-dashboard" ? "border-b font-bold" : "font-normal"}`}
            //             >Admin
            //         </Link>
            //     </div>
            //   </div>
            //   : ""
            // }
              
            // </li>
            }
            <>  </>
          
            {/* <button 
                className=" md:hidden rounded-full cursor-pointer font-montserrat text-white bg-primary40 py-2 px-4 text-sm md:text-base lg:ml-[66px] w-[260px]"
                onClick={() => ConnectWallet()}>
                {connectedAccount ? `${connectedAccount.slice(0, 5) + "..." + connectedAccount.slice(connectedAccount.length - 5, connectedAccount.length)} `: "Connect Wallets"}
            </button> */}
              

            </ul>
            
            <ConnectWalletButton/>
            {/* <button 
                className="hidden md:block rounded-full cursor-pointer font-montserrat text-white bg-primary40 py-2 px-4 text-sm md:text-base lg:ml-[66px] w-[260px]"
                onClick={ConnectWallet}>
                {connectedAccount ? `${connectedAccount.slice(0, 5) + "..." + connectedAccount.slice(connectedAccount.length - 5, connectedAccount.length)}` : "Connect Wallets" }
            </button> */}
               
    
            

            {/* toggle  menu */}
            <button className="md:hidden md:ml-5" onClick={toggleMenu}>
              {toggle_menu ? <MdClose color="#006D44" size={28} /> : <img src={menuIcon} alt="menu-icon" />}
            </button>
          </div>
        </div>
      </div>
    </header>
  );
}

export default Header