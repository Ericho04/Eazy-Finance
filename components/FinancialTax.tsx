import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { Progress } from "./ui/progress";
import { Separator } from "./ui/separator";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Alert, AlertDescription } from "./ui/alert";
import { 
  ArrowLeft,
  Calculator,
  FileText,
  Upload,
  Download,
  CheckCircle,
  Clock,
  AlertCircle,
  Calendar,
  Receipt,
  BarChart3,
  Plus,
  Info,
  DollarSign,
  TrendingDown
} from "lucide-react";
import { motion } from "motion/react";

interface FinancialTaxProps {
  onBack: () => void;
}

interface TaxRelief {
  id: string;
  category: string;
  description: string;
  amount: number;
  maxLimit: number;
  documents: string[];
  status: 'pending' | 'submitted' | 'approved';
}

interface TaxDocument {
  id: string;
  name: string;
  type: 'EA_form' | 'receipt' | 'certificate' | 'statement' | 'other';
  uploadDate: string;
  taxYear: string;
  size: string;
}

interface TaxDeadline {
  id: string;
  title: string;
  date: string;
  type: 'submission' | 'payment' | 'reminder';
  status: 'upcoming' | 'overdue' | 'completed';
  description: string;
}

export function FinancialTax({ onBack }: FinancialTaxProps) {
  const [annualIncome, setAnnualIncome] = useState(60000);
  const [epfContribution, setEpfContribution] = useState(7200);
  const [socsoContribution, setSocsoContribution] = useState(3600);
  
  // Demo tax data
  const [taxReliefs] = useState<TaxRelief[]>([
    {
      id: '1',
      category: 'Life Insurance Premium',
      description: 'Personal and spouse insurance premiums',
      amount: 2800,
      maxLimit: 3000,
      documents: ['insurance_policy.pdf', 'premium_receipt.pdf'],
      status: 'approved'
    },
    {
      id: '2',
      category: 'Medical Expenses',
      description: 'Medical treatment and health screening',
      amount: 1200,
      maxLimit: 8000,
      documents: ['medical_receipt_1.pdf', 'medical_receipt_2.pdf'],
      status: 'submitted'
    },
    {
      id: '3',
      category: 'Education Fees',
      description: 'Self and child education expenses',
      amount: 4500,
      maxLimit: 7000,
      documents: ['education_receipt.pdf'],
      status: 'pending'
    },
    {
      id: '4',
      category: 'SSPN Contribution',
      description: 'Education savings plan contribution',
      amount: 8000,
      maxLimit: 8000,
      documents: ['sspn_statement.pdf'],
      status: 'approved'
    }
  ]);

  const [taxDocuments] = useState<TaxDocument[]>([
    {
      id: '1',
      name: 'EA Form 2023 - Company ABC',
      type: 'EA_form',
      uploadDate: '2024-02-15',
      taxYear: '2023',
      size: '2.1 MB'
    },
    {
      id: '2',
      name: 'Medical Receipt - Hospital KL',
      type: 'receipt',
      uploadDate: '2024-01-20',
      taxYear: '2023',
      size: '1.5 MB'
    },
    {
      id: '3',
      name: 'Insurance Premium Statement',
      type: 'statement',
      uploadDate: '2024-01-10',
      taxYear: '2023',
      size: '800 KB'
    }
  ]);

  const [taxDeadlines] = useState<TaxDeadline[]>([
    {
      id: '1',
      title: 'Individual Tax Return (BE Form)',
      date: '2024-04-30',
      type: 'submission',
      status: 'upcoming',
      description: 'Submit individual income tax return for assessment year 2024'
    },
    {
      id: '2',
      title: 'Tax Payment Deadline',
      date: '2024-07-31',
      type: 'payment',
      status: 'upcoming',
      description: 'Final deadline for tax payment without penalty'
    },
    {
      id: '3',
      title: 'EA Form Collection',
      date: '2024-03-31',
      type: 'reminder',
      status: 'completed',
      description: 'Collect EA form from employer'
    }
  ]);

  // Tax calculations (Malaysian tax brackets 2024)
  const calculateMalaysianTax = (income: number, epf: number, socso: number) => {
    const taxableIncome = Math.max(0, income - epf - socso);
    let tax = 0;

    if (taxableIncome <= 5000) tax = 0;
    else if (taxableIncome <= 20000) tax = (taxableIncome - 5000) * 0.01;
    else if (taxableIncome <= 35000) tax = 150 + (taxableIncome - 20000) * 0.03;
    else if (taxableIncome <= 50000) tax = 600 + (taxableIncome - 35000) * 0.08;
    else if (taxableIncome <= 70000) tax = 1800 + (taxableIncome - 50000) * 0.13;
    else if (taxableIncome <= 100000) tax = 4400 + (taxableIncome - 70000) * 0.21;
    else if (taxableIncome <= 400000) tax = 10700 + (taxableIncome - 100000) * 0.24;
    else if (taxableIncome <= 600000) tax = 82700 + (taxableIncome - 400000) * 0.245;
    else if (taxableIncome <= 2000000) tax = 131700 + (taxableIncome - 600000) * 0.25;
    else tax = 481700 + (taxableIncome - 2000000) * 0.28;

    return Math.round(tax);
  };

  const totalTaxReliefs = taxReliefs.reduce((sum, relief) => sum + relief.amount, 0);
  const estimatedTax = calculateMalaysianTax(annualIncome, epfContribution, socsoContribution);
  const taxAfterReliefs = Math.max(0, estimatedTax - totalTaxReliefs);
  const effectiveTaxRate = annualIncome > 0 ? (taxAfterReliefs / annualIncome) * 100 : 0;
  const taxSavings = estimatedTax - taxAfterReliefs;

  const formatCurrency = (amount: number) => {
    return `RM ${amount.toLocaleString('en-MY', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`;
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'EA_form': return <FileText className="w-4 h-4" />;
      case 'receipt': return <Receipt className="w-4 h-4" />;
      case 'certificate': return <CheckCircle className="w-4 h-4" />;
      case 'statement': return <BarChart3 className="w-4 h-4" />;
      default: return <FileText className="w-4 h-4" />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved':
      case 'completed':
        return 'text-[color:var(--sfms-success)] bg-[color:var(--sfms-success-light)]';
      case 'submitted':
      case 'upcoming':
        return 'text-[color:var(--sfms-warning)] bg-[color:var(--sfms-warning-light)]';
      case 'pending':
        return 'text-[color:var(--sfms-neutral-dark)] bg-[color:var(--sfms-neutral-light)]';
      case 'overdue':
        return 'text-[color:var(--sfms-danger)] bg-[color:var(--sfms-danger-light)]';
      default:
        return 'text-muted-foreground bg-muted';
    }
  };

  const getDaysUntil = (dateStr: string) => {
    const targetDate = new Date(dateStr);
    const today = new Date();
    const diffTime = targetDate.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  return (
    <div className="pb-6 px-4 space-y-6">
      {/* Header */}
      <div className="pt-6">
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="flex items-center gap-4"
        >
          <Button
            variant="ghost"
            size="sm"
            onClick={onBack}
            className="p-2"
          >
            <ArrowLeft className="w-4 h-4" />
          </Button>
          <div className="flex-1">
            <h1 className="text-2xl text-purple-700">Tax Planning</h1>
            <p className="text-muted-foreground">Malaysian income tax management</p>
          </div>
        </motion.div>
      </div>

      {/* Summary Cards */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.1 }}
        className="grid grid-cols-3 gap-3"
      >
        <Card className="border-purple-200">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <Calculator className="w-4 h-4 text-purple-600" />
              <span className="text-xs font-medium">Est. Tax</span>
            </div>
            <p className={`text-lg font-bold ${taxAfterReliefs > 0 ? 'text-[color:var(--sfms-danger)]' : 'text-[color:var(--sfms-success)]'}`}>
              {formatCurrency(taxAfterReliefs)}
            </p>
          </CardContent>
        </Card>

        <Card className="border-[color:var(--sfms-success)]/20">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <TrendingDown className="w-4 h-4 text-[color:var(--sfms-success)]" />
              <span className="text-xs font-medium">Tax Savings</span>
            </div>
            <p className="text-lg font-bold text-[color:var(--sfms-success)]">
              {formatCurrency(taxSavings)}
            </p>
          </CardContent>
        </Card>

        <Card className="border-[color:var(--sfms-ai)]/20">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <DollarSign className="w-4 h-4 text-[color:var(--sfms-ai)]" />
              <span className="text-xs font-medium">Tax Rate</span>
            </div>
            <p className="text-lg font-bold text-[color:var(--sfms-ai)]">
              {effectiveTaxRate.toFixed(1)}%
            </p>
          </CardContent>
        </Card>
      </motion.div>

      {/* Tax Calculator */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.2 }}
      >
        <Card className="border-2 border-purple-200 shadow-lg bg-gradient-to-br from-purple-50 to-white">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-purple-700">
              <Calculator className="w-5 h-5" />
              Tax Calculator 2024
            </CardTitle>
            <CardDescription>Malaysian Income Tax Calculation</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {/* Income Inputs */}
            <div className="grid grid-cols-1 gap-4">
              <div className="space-y-2">
                <Label htmlFor="annual-income">Annual Income (RM)</Label>
                <Input
                  id="annual-income"
                  type="number"
                  value={annualIncome}
                  onChange={(e) => setAnnualIncome(Number(e.target.value))}
                  className="font-medium"
                />
              </div>
              
              <div className="grid grid-cols-2 gap-2">
                <div className="space-y-2">
                  <Label htmlFor="epf">EPF Contribution</Label>
                  <Input
                    id="epf"
                    type="number"
                    value={epfContribution}
                    onChange={(e) => setEpfContribution(Number(e.target.value))}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="socso">SOCSO Contribution</Label>
                  <Input
                    id="socso"
                    type="number"
                    value={socsoContribution}
                    onChange={(e) => setSocsoContribution(Number(e.target.value))}
                  />
                </div>
              </div>
            </div>

            <Separator />

            {/* Tax Calculation Summary */}
            <div className="space-y-3">
              <div className="flex justify-between">
                <span>Gross Income:</span>
                <span className="font-bold">{formatCurrency(annualIncome)}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span>EPF Deduction:</span>
                <span>-{formatCurrency(epfContribution)}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span>SOCSO Deduction:</span>
                <span>-{formatCurrency(socsoContribution)}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span>Tax Reliefs:</span>
                <span className="text-[color:var(--sfms-success)]">-{formatCurrency(totalTaxReliefs)}</span>
              </div>
              
              <Separator />
              
              <div className="flex justify-between text-lg">
                <span>Final Tax:</span>
                <span className={`font-bold ${taxAfterReliefs > 0 ? 'text-[color:var(--sfms-danger)]' : 'text-[color:var(--sfms-success)]'}`}>
                  {formatCurrency(taxAfterReliefs)}
                </span>
              </div>
              <div className="flex justify-between text-sm text-muted-foreground">
                <span>Effective Tax Rate:</span>
                <span>{effectiveTaxRate.toFixed(2)}%</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </motion.div>

      {/* Tax Relief Claims */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.3 }}
      >
        <Card className="shadow-lg">
          <CardHeader>
            <div className="flex justify-between items-center">
              <div>
                <CardTitle className="text-[color:var(--sfms-success)]">Tax Relief Claims</CardTitle>
                <CardDescription>
                  Total Relief: {formatCurrency(totalTaxReliefs)}
                </CardDescription>
              </div>
              <Button size="sm" className="gradient-success text-white">
                <Plus className="w-4 h-4 mr-1" />
                Add Relief
              </Button>
            </div>
          </CardHeader>
          <CardContent className="space-y-3">
            {taxReliefs.map((relief, index) => (
              <motion.div
                key={relief.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.3, delay: 0.4 + index * 0.1 }}
                className="p-3 rounded-lg bg-[color:var(--sfms-neutral-light)]"
              >
                <div className="flex items-center justify-between mb-2">
                  <div>
                    <p className="font-medium">{relief.category}</p>
                    <p className="text-xs text-muted-foreground">{relief.description}</p>
                  </div>
                  <Badge className={getStatusColor(relief.status)}>
                    {relief.status}
                  </Badge>
                </div>
                <div className="flex justify-between items-center">
                  <span className="font-bold text-[color:var(--sfms-success)]">
                    {formatCurrency(relief.amount)}
                  </span>
                  <div className="text-right">
                    <p className="text-xs text-muted-foreground">
                      Max: {formatCurrency(relief.maxLimit)}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      {relief.documents.length} documents
                    </p>
                  </div>
                </div>
                <Progress 
                  value={(relief.amount / relief.maxLimit) * 100} 
                  className="h-1 mt-2" 
                />
              </motion.div>
            ))}
          </CardContent>
        </Card>
      </motion.div>

      {/* Tax Documents */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.4 }}
      >
        <Card className="shadow-lg">
          <CardHeader>
            <div className="flex justify-between items-center">
              <div>
                <CardTitle className="text-[color:var(--sfms-warning)]">Tax Documents</CardTitle>
                <CardDescription>Upload and manage tax-related documents</CardDescription>
              </div>
              <Button size="sm" variant="outline">
                <Upload className="w-4 h-4 mr-1" />
                Upload
              </Button>
            </div>
          </CardHeader>
          <CardContent className="space-y-3">
            {taxDocuments.map((doc, index) => (
              <motion.div
                key={doc.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.3, delay: 0.5 + index * 0.1 }}
                className="p-3 rounded-lg bg-[color:var(--sfms-neutral-light)]"
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    {getTypeIcon(doc.type)}
                    <div>
                      <p className="font-medium">{doc.name}</p>
                      <p className="text-xs text-muted-foreground">
                        {doc.taxYear} • {doc.size} • {doc.uploadDate}
                      </p>
                    </div>
                  </div>
                  <Button size="sm" variant="ghost">
                    <Download className="w-4 h-4" />
                  </Button>
                </div>
              </motion.div>
            ))}
          </CardContent>
        </Card>
      </motion.div>

      {/* Tax Deadlines */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.5 }}
      >
        <Card className="shadow-lg">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-[color:var(--sfms-danger)]">
              <Calendar className="w-5 h-5" />
              Important Deadlines
            </CardTitle>
            <CardDescription>Stay on top of tax submission and payment dates</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {taxDeadlines.map((deadline, index) => {
              const daysUntil = getDaysUntil(deadline.date);
              const isOverdue = daysUntil < 0;
              const isUrgent = daysUntil <= 30 && daysUntil >= 0;
              
              return (
                <motion.div
                  key={deadline.id}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ duration: 0.3, delay: 0.6 + index * 0.1 }}
                  className="p-3 rounded-lg bg-[color:var(--sfms-neutral-light)]"
                >
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center gap-2">
                      {deadline.status === 'completed' ? (
                        <CheckCircle className="w-4 h-4 text-[color:var(--sfms-success)]" />
                      ) : isOverdue ? (
                        <AlertCircle className="w-4 h-4 text-[color:var(--sfms-danger)]" />
                      ) : (
                        <Clock className="w-4 h-4 text-[color:var(--sfms-warning)]" />
                      )}
                      <span className="font-medium">{deadline.title}</span>
                    </div>
                    <Badge className={getStatusColor(deadline.status)}>
                      {deadline.status}
                    </Badge>
                  </div>
                  <div className="flex justify-between items-center">
                    <div>
                      <p className="text-sm">{deadline.description}</p>
                      <p className="text-xs text-muted-foreground">Due: {deadline.date}</p>
                    </div>
                    <div className="text-right">
                      {deadline.status !== 'completed' && (
                        <p className={`text-sm font-medium ${
                          isOverdue ? 'text-[color:var(--sfms-danger)]' : 
                          isUrgent ? 'text-[color:var(--sfms-warning)]' : 
                          'text-[color:var(--sfms-success)]'
                        }`}>
                          {isOverdue ? `${Math.abs(daysUntil)} days overdue` : 
                           `${daysUntil} days left`}
                        </p>
                      )}
                    </div>
                  </div>
                </motion.div>
              );
            })}
          </CardContent>
        </Card>
      </motion.div>

      {/* Tax Tips */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.6 }}
      >
        <Alert className="border-purple-200 bg-purple-50">
          <Info className="h-4 w-4 text-purple-600" />
          <AlertDescription className="text-purple-700">
            <span className="font-medium">Tax Tip:</span> Maximize your EPF contributions up to RM4,000 
            and utilize all available tax relief categories to reduce your tax liability.
          </AlertDescription>
        </Alert>
      </motion.div>

      {/* Action Buttons */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.7 }}
        className="grid grid-cols-2 gap-3"
      >
        <Button variant="outline" className="h-12">
          <FileText className="w-4 h-4 mr-2" />
          Generate Report
        </Button>
        <Button className="gradient-ai text-white h-12">
          <Calculator className="w-4 h-4 mr-2" />
          Tax Optimization
        </Button>
      </motion.div>
    </div>
  );
}