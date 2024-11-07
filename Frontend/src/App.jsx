import WalletBar from "./WalletBar"
import { MainRoutes } from './routes/index';
import { UserDashboardRoutes } from './routes/dashboard/user.jsx';
import { CompanyDashboardRoutes } from './routes/dashboard/company.jsx';
import { AdminDashboardRoutes } from "./routes/dashboard/admin.jsx";

function App() {
  return (
    <>
      <WalletBar/>
      <MainRoutes />
      <UserDashboardRoutes />
      <CompanyDashboardRoutes />
      <AdminDashboardRoutes />
    </>
  )
}

export default App
